<?php

namespace App\Console\Commands;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\StatusPost;
use App\Models\User;
use App\Services\ChineseZodiacService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class DevSyntheticUsersCommand extends Command
{
    protected $signature = 'app:dev:synthetic-users
        {--count=1000 : Number of synthetic users to create}
        {--batch= : Optional batch tag (default auto timestamp)}
        {--batch-id= : Optional stable batch identifier (default batch tag)}
        {--generation-version=v1 : Synthetic generation version tag}
        {--visibility-scope=square : Synthetic visibility scope marker}
        {--seed= : Optional reproducible seed}
        {--summary : Print batch summary and exit}
        {--disable-batch= : Disable all synthetic users in the given batch and exit}
        {--cleanup-batch= : Delete all synthetic users in the given batch and exit}
        {--rebuild-batch= : Clear the named batch first, then recreate it}
        {--with-answers=1 : Whether to auto fill required questionnaire answers (0|1)}
        {--password= : Optional password for synthetic users (if empty, auto-generate random strong password)}
        {--phone-prefix=90 : Synthetic phone prefix (default 90, avoid real mobile ranges)}
        {--cities=北京,上海,广州,深圳,南阳 : Comma separated city pool}
        {--min-age=24 : Minimum age}
        {--max-age=36 : Maximum age}
        {--clear-batch= : Optional batch tag to delete before create}
        {--only-clear : Only clear batch and exit}';

    protected $description = 'Generate (or clear) synthetic users for matching algorithm debugging/load tests.';

    private function ensureSyntheticOpsAllowed(): bool
    {
        if (!app()->environment('production')) {
            return true;
        }
        $allow = (bool) config('matching.debug.allow_synthetic_commands_in_production', false);
        if ($allow) {
            return true;
        }
        $this->error('Blocked in production: synthetic command is disabled. Set MATCHING_ALLOW_SYNTHETIC_COMMANDS_IN_PRODUCTION=true only for controlled operations.');
        return false;
    }

    public function handle(ChineseZodiacService $zodiacService): int
    {
        if (!$this->ensureSyntheticOpsAllowed()) {
            return self::FAILURE;
        }

        $count = max(0, (int) $this->option('count'));
        $batch = trim((string) $this->option('batch'));
        if ($batch === '') {
            $batch = 'syn_'.now()->format('Ymd_His');
        }
        $batchId = trim((string) $this->option('batch-id'));
        if ($batchId === '') {
            $batchId = $batch;
        }
        $generationVersion = trim((string) $this->option('generation-version'));
        if ($generationVersion === '') {
            $generationVersion = 'v1';
        }
        $visibilityScope = $this->normalizeVisibilityScope((string) $this->option('visibility-scope'));
        $seedOption = trim((string) $this->option('seed'));
        $seedBase = $seedOption !== ''
            ? (int) $seedOption
            : abs((int) crc32($batch.'|'.$batchId.'|'.$generationVersion.'|'.$count));
        $summaryOnly = in_array((string) $this->option('summary'), ['1', 'true', 'yes', 'on'], true);
        $disableBatch = trim((string) $this->option('disable-batch'));
        $cleanupBatch = trim((string) $this->option('cleanup-batch'));
        $rebuildBatch = trim((string) $this->option('rebuild-batch'));
        $withAnswers = in_array((string) $this->option('with-answers'), ['1', 'true', 'yes', 'on'], true);
        $password = trim((string) $this->option('password'));
        if ($password === '') {
            $password = $this->generateStrongPassword();
        }
        $phonePrefix = trim((string) $this->option('phone-prefix'));
        if ($phonePrefix === '' || preg_match('/\D/', $phonePrefix)) {
            $phonePrefix = '90';
        }
        $cities = $this->parseCities((string) $this->option('cities'));
        $minAge = max(18, (int) $this->option('min-age'));
        $maxAge = max($minAge, (int) $this->option('max-age'));
        $clearBatch = trim((string) $this->option('clear-batch'));
        $onlyClear = (bool) $this->option('only-clear');

        if ($cleanupBatch !== '' && $clearBatch === '') {
            $clearBatch = $cleanupBatch;
        }
        if ($rebuildBatch !== '') {
            $batch = $rebuildBatch;
            $batchId = $rebuildBatch;
            if ($cleanupBatch === '') {
                $cleanupBatch = $rebuildBatch;
            }
            if ($clearBatch === '') {
                $clearBatch = $rebuildBatch;
            }
        }

        if ($summaryOnly) {
            $this->printBatchSummary($batchId !== '' ? $batchId : $batch);
            return self::SUCCESS;
        }

        if ($disableBatch !== '') {
            $updated = $this->disableBatch($disableBatch);
            $this->info("Disabled synthetic batch {$disableBatch}: {$updated} users");
            $this->printBatchSummary($disableBatch);
            return self::SUCCESS;
        }

        if ($clearBatch !== '') {
            $deleted = $this->clearBatch($clearBatch);
            $this->info("Cleared synthetic batch {$clearBatch}: {$deleted} users");
            if ($onlyClear || ($cleanupBatch !== '' && $rebuildBatch === '')) {
                return self::SUCCESS;
            }
        }

        if ($count <= 0) {
            $this->warn('No users created: --count <= 0');
            return self::SUCCESS;
        }

        $requiredAnswers = max(1, (int) config('questionnaire.required_answer_count', 20));
        $questions = collect();
        if ($withAnswers) {
            $questions = QuestionnaireQuestion::query()
                ->where('enabled', true)
                ->orderBy('sort_order')
                ->limit($requiredAnswers)
                ->get(['id', 'options']);

            if ($questions->count() < $requiredAnswers) {
                $this->error("Insufficient enabled questions: need {$requiredAnswers}, got {$questions->count()}");
                return self::FAILURE;
            }
        }

        $created = 0;
        $answersUpsertRows = [];
        $passwordHash = Hash::make($password);
        $zodiacPool = ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'];
        $mbtiPool = ['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP', 'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP'];
        $seedBase = abs($seedBase) > 0 ? abs($seedBase) : 1;
        DB::beginTransaction();
        try {
            for ($i = 0; $i < $count; $i++) {
                $userSeed = $seedBase + ($i * 97);
                $phone = $this->nextPhone($phonePrefix, $userSeed, $i);
                $city = $this->pickBySeed($cities, $userSeed + 11);
                $birthday = $this->randomBirthday($minAge, $maxAge, $userSeed + 17);
                $gender = $this->pickBySeed(['male', 'female'], $userSeed + 23);
                $goal = $this->pickBySeed(['marriage', 'dating', 'friendship'], $userSeed + 31);
                $mbti = $this->pickBySeed($mbtiPool, $userSeed + 43);
                $zodiac = $this->pickBySeed($zodiacPool, $userSeed + 59);
                $personality = $this->randomPersonalityVector($userSeed + 71);
                $coord = $this->cityCoordinate($city);
                $cleanupToken = substr(hash('sha256', implode('|', [$batch, $batchId, $seedBase, $i, $phone])), 0, 32);
                $accountVisibility = $visibilityScope;
                $isMatchEligible = $visibilityScope !== 'hidden';
                $isSquareVisible = in_array($visibilityScope, ['square', 'all'], true);

                $attributes = [
                    'phone' => $phone,
                    'name' => "SYN_{$batch}_".str_pad((string) ($i + 1), 4, '0', STR_PAD_LEFT),
                    'password' => $passwordHash,
                    'role' => 'user',
                    'account_type' => 'test',
                    'verify_status' => 'approved',
                    'realname_verified' => true,
                    'disabled' => false,
                    'is_synthetic' => true,
                    'synthetic_batch' => $batch,
                    'is_match_eligible' => $isMatchEligible,
                    'is_square_visible' => $isSquareVisible,
                    'exclude_from_metrics' => true,
                    'banned_reason' => null,
                    'birthday' => $birthday,
                    'zodiac_animal' => $zodiacService->fromBirthdayString($birthday),
                    'gender' => $gender,
                    'city' => $city,
                    'relationship_goal' => $goal,
                    'public_zodiac_sign' => $zodiac,
                    'public_mbti' => $mbti,
                    'public_personality' => $personality,
                    'private_birth_place' => $city,
                    'private_birth_lat' => $coord['lat'],
                    'private_birth_lng' => $coord['lng'],
                ];
                $attributes['synthetic_batch_id'] = $batchId;
                $attributes['synthetic_seed'] = $userSeed;
                $attributes['generation_version'] = $generationVersion;
                $attributes['account_status'] = 'active';
                $attributes['visibility_scope'] = $accountVisibility;
                $attributes['cleanup_token'] = $cleanupToken;

                $user = User::create($attributes);
                $created++;

                StatusPost::create([
                    'author_user_id' => (int) $user->id,
                    'title' => $this->syntheticStatusTitle($city, $i + 1),
                    'body' => $this->syntheticStatusBody($city, $goal, $gender, $zodiac),
                    'location_name' => $city,
                    'visibility' => 'public',
                    'is_deleted' => false,
                    'deleted_by_user_id' => null,
                    'deleted_at' => null,
                ]);

                if ($withAnswers) {
                    foreach ($questions as $q) {
                        $optionIds = collect((array) $q->options)
                            ->pluck('option_id')
                            ->filter(fn ($v) => is_string($v) && trim($v) !== '')
                            ->map(fn ($v) => trim((string) $v))
                            ->values()
                            ->all();
                        if (count($optionIds) === 0) {
                            continue;
                        }

                        $selected = $optionIds[array_rand($optionIds)];
                        $acceptable = [$selected];
                        if (count($optionIds) >= 2 && random_int(0, 1) === 1) {
                            $another = $selected;
                            while ($another === $selected) {
                                $another = $optionIds[array_rand($optionIds)];
                            }
                            $acceptable[] = $another;
                        }

                        $importance = random_int(1, 3);
                        $answersUpsertRows[] = [
                            'user_id' => (int) $user->id,
                            'questionnaire_question_id' => (int) $q->id,
                            'answer_payload' => json_encode([
                                'value' => $selected,
                                'selected_answer' => [$selected],
                                'acceptable_answers' => array_values(array_unique($acceptable)),
                                'importance' => $importance,
                                'version' => 1,
                            ], JSON_UNESCAPED_UNICODE),
                            'selected_answer_json' => json_encode([$selected], JSON_UNESCAPED_UNICODE),
                            'acceptable_answers_json' => json_encode(array_values(array_unique($acceptable)), JSON_UNESCAPED_UNICODE),
                            'importance' => $importance,
                            'version' => 1,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ];
                    }
                }
            }

            if (!empty($answersUpsertRows)) {
                foreach (array_chunk($answersUpsertRows, 500) as $chunk) {
                    QuestionnaireAnswer::query()->upsert(
                        $chunk,
                        ['user_id', 'questionnaire_question_id'],
                        ['answer_payload', 'selected_answer_json', 'acceptable_answers_json', 'importance', 'version', 'updated_at']
                    );
                }
            }

            DB::commit();
        } catch (\Throwable $e) {
            DB::rollBack();
            $this->error('Synthetic generation failed: '.$e->getMessage());
            return self::FAILURE;
        }

        $this->info("Synthetic users created: {$created}");
        $this->line("batch={$batch}");
        $this->line("batch_id={$batchId}");
        $this->line("generation_version={$generationVersion}");
        $this->line("visibility_scope={$visibilityScope}");
        $this->line("seed={$seedBase}");
        $this->line("with_answers=".($withAnswers ? 'true' : 'false'));
        $this->line('cities='.implode(',', $cities));
        $this->line("age_range={$minAge}-{$maxAge}");
        $this->line("phone_prefix={$phonePrefix}");
        $this->line("synthetic_password={$password}");

        $this->printBatchSummary($batchId);

        return self::SUCCESS;
    }

    private function clearBatch(string $batch): int
    {
        return User::query()
            ->where('is_synthetic', true)
            ->where(function ($query) use ($batch) {
                $query->where('synthetic_batch', $batch)
                    ->orWhere('synthetic_batch_id', $batch);
            })
            ->delete();
    }

    private function disableBatch(string $batch): int
    {
        $payload = [
            'disabled' => true,
            'is_match_eligible' => false,
            'is_square_visible' => false,
            'exclude_from_metrics' => true,
        ];
        $payload['account_status'] = 'disabled';
        $payload['visibility_scope'] = 'hidden';

        return User::query()
            ->where('is_synthetic', true)
            ->where(function ($query) use ($batch) {
                $query->where('synthetic_batch', $batch)
                    ->orWhere('synthetic_batch_id', $batch);
            })
            ->update($payload);
    }

    private function printBatchSummary(string $batch): void
    {
        $query = User::query()
            ->where('is_synthetic', true)
            ->where(function ($inner) use ($batch) {
                $inner->where('synthetic_batch', $batch)
                    ->orWhere('synthetic_batch_id', $batch);
            });

        $total = (clone $query)->count();
        $active = (clone $query)->where('disabled', false)->count();
        $disabled = (clone $query)->where('disabled', true)->count();
        $visible = (clone $query)->where('is_square_visible', true)->count();
        $eligible = (clone $query)->where('is_match_eligible', true)->count();
        $metricsExcluded = (clone $query)->where('exclude_from_metrics', true)->count();
        $sample = (clone $query)->orderBy('id')->limit(3)->get(['id', 'phone', 'name', 'account_status', 'visibility_scope']);

        $this->line('batch_summary='.json_encode([
            'batch' => $batch,
            'total' => $total,
            'active' => $active,
            'disabled' => $disabled,
            'visible' => $visible,
            'eligible' => $eligible,
            'metrics_excluded' => $metricsExcluded,
            'sample' => $sample->map(fn ($user) => [
                'id' => (int) $user->id,
                'phone' => (string) $user->phone,
                'name' => (string) $user->name,
                'account_status' => (string) ($user->account_status ?? 'active'),
                'visibility_scope' => (string) ($user->visibility_scope ?? 'square'),
            ])->values()->all(),
        ], JSON_UNESCAPED_UNICODE));
    }

    private function nextPhone(string $prefix, int $seed, int $index): string
    {
        // Use a non-mobile synthetic prefix by default (e.g. 90xxxx...), to avoid
        // confusing with real phone accounts.
        $normalized = preg_replace('/\D+/', '', $prefix) ?? '90';
        if ($normalized === '') {
            $normalized = '90';
        }
        if (strlen($normalized) >= 11) {
            $normalized = substr($normalized, 0, 10);
        }
        $suffixLen = 11 - strlen($normalized);
        if ($suffixLen < 1) {
            $suffixLen = 1;
        }

        $attempt = 0;
        while (true) {
            $max = (10 ** $suffixLen) - 1;
            $candidateSeed = $seed + ($index * 131) + $attempt;
            $phone = $normalized.str_pad((string) $this->pseudoRand($candidateSeed, 0, $max), $suffixLen, '0', STR_PAD_LEFT);
            $exists = User::query()->where('phone', $phone)->exists();
            if (!$exists) {
                return $phone;
            }
            $attempt++;
        }
    }

    private function generateStrongPassword(int $length = 12): string
    {
        $alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz23456789!@#$%^&*';
        $max = strlen($alphabet) - 1;
        $out = '';
        for ($i = 0; $i < $length; $i++) {
            $out .= $alphabet[random_int(0, $max)];
        }
        return $out;
    }

    private function syntheticStatusTitle(string $city, int $index): string
    {
        $city = trim($city);
        if ($city === '') {
            $city = '同城';
        }
        $templates = [
            "今天在{$city}想找个人聊聊天",
            "{$city}的晚风很适合认识新朋友",
            "刚下班，想在{$city}找个轻松话题",
            "{$city}周末有没有适合散步的地方",
        ];

        return $templates[($index - 1) % count($templates)];
    }

    private function syntheticStatusBody(string $city, string $goal, string $gender, string $zodiac): string
    {
        $goalText = match ($goal) {
            'marriage' => '认真看待关系',
            'dating' => '想认真了解彼此',
            default => '先从轻松聊天开始',
        };
        $genderText = $gender === 'female' ? '女生' : '男生';
        $city = trim($city) === '' ? '同城' : trim($city);

        return "{$genderText}，{$goalText}，在{$city}等一个自然的开场。{$zodiac}，今天想先聊轻松一点的话题。";
    }

    /**
     * @return array<int,string>
     */
    private function parseCities(string $cities): array
    {
        $items = array_values(array_filter(array_map(
            static fn (string $v) => trim($v),
            explode(',', $cities)
        )));

        if (empty($items)) {
            return ['北京', '上海', '广州', '深圳', '南阳'];
        }

        return array_values(array_unique($items));
    }

    private function randomBirthday(int $minAge, int $maxAge, int $seed): string
    {
        $age = $this->pseudoRand($seed, $minAge, $maxAge);
        $start = now()->subYears($age + 1)->addDay();
        $end = now()->subYears($age);
        $days = max(1, $start->diffInDays($end));
        return $start->addDays($this->pseudoRand($seed + 7, 0, $days))->format('Y-m-d');
    }

    /**
     * @return array<string,mixed>
     */
    private function randomPersonalityVector(int $seed): array
    {
        return [
            'openness' => $this->pseudoRand($seed + 3, 35, 95),
            'conscientiousness' => $this->pseudoRand($seed + 7, 35, 95),
            'extraversion' => $this->pseudoRand($seed + 11, 20, 95),
            'agreeableness' => $this->pseudoRand($seed + 13, 30, 95),
            'neuroticism' => $this->pseudoRand($seed + 17, 10, 90),
        ];
    }

    /**
     * @return array{lat:float,lng:float}
     */
    private function cityCoordinate(string $city): array
    {
        $map = [
            '北京' => ['lat' => 39.9042, 'lng' => 116.4074],
            '上海' => ['lat' => 31.2304, 'lng' => 121.4737],
            '广州' => ['lat' => 23.1291, 'lng' => 113.2644],
            '深圳' => ['lat' => 22.5431, 'lng' => 114.0579],
            '南阳' => ['lat' => 32.9907, 'lng' => 112.5283],
        ];

        return $map[$city] ?? ['lat' => 32.9907, 'lng' => 112.5283];
    }

    /**
     * @template T
     * @param array<int,T> $items
     * @return T
     */
    private function pickBySeed(array $items, int $seed)
    {
        if (empty($items)) {
            throw new \RuntimeException('pickBySeed requires a non-empty item list.');
        }

        $idx = $this->pseudoRand($seed, 0, max(0, count($items) - 1));
        return $items[$idx];
    }

    private function pseudoRand(int $seed, int $min, int $max): int
    {
        if ($min >= $max) {
            return $min;
        }

        $n = abs((int) (($seed * 1103515245 + 12345) & 0x7fffffff));
        return $min + ($n % ($max - $min + 1));
    }

    private function normalizeVisibilityScope(string $scope): string
    {
        $scope = trim(strtolower($scope));
        if ($scope === '') {
            return 'square';
        }

        return in_array($scope, ['square', 'hidden', 'all', 'match'], true) ? $scope : 'square';
    }
}
