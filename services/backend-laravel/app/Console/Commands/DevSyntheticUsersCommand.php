<?php

namespace App\Console\Commands;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
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

        if ($clearBatch !== '') {
            $deleted = $this->clearBatch($clearBatch);
            $this->info("Cleared synthetic batch {$clearBatch}: {$deleted} users");
            if ($onlyClear) {
                return self::SUCCESS;
            }
        }

        if ($count <= 0) {
            $this->warn('No users created: --count <= 0');
            return self::SUCCESS;
        }

        $requiredAnswers = max(1, (int) config('questionnaire.required_answer_count', 20));
        $questions = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->orderBy('sort_order')
            ->limit($requiredAnswers)
            ->get(['id', 'options']);

        if ($withAnswers && $questions->count() < $requiredAnswers) {
            $this->error("Insufficient enabled questions: need {$requiredAnswers}, got {$questions->count()}");
            return self::FAILURE;
        }

        $created = 0;
        $answersUpsertRows = [];
        $passwordHash = Hash::make($password);
        $zodiacPool = ['白羊座', '金牛座', '双子座', '巨蟹座', '狮子座', '处女座', '天秤座', '天蝎座', '射手座', '摩羯座', '水瓶座', '双鱼座'];
        $mbtiPool = ['INTJ', 'INTP', 'ENTJ', 'ENTP', 'INFJ', 'INFP', 'ENFJ', 'ENFP', 'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ', 'ISTP', 'ISFP', 'ESTP', 'ESFP'];
        $cityCursor = 0;
        $cityShuffle = $cities;
        shuffle($cityShuffle);

        DB::beginTransaction();
        try {
            for ($i = 0; $i < $count; $i++) {
                $phone = $this->nextPhone($phonePrefix);
                if ($cityCursor > 0 && $cityCursor % count($cityShuffle) === 0) {
                    shuffle($cityShuffle);
                }
                $city = $cityShuffle[$cityCursor % count($cityShuffle)];
                $cityCursor++;
                $birthday = $this->randomBirthday($minAge, $maxAge);
                $gender = random_int(0, 1) === 0 ? 'male' : 'female';
                $goal = ['marriage', 'dating', 'friendship'][random_int(0, 2)];
                $mbti = $mbtiPool[array_rand($mbtiPool)];
                $zodiac = $zodiacPool[array_rand($zodiacPool)];
                $personality = $this->randomPersonalityVector();
                $coord = $this->cityCoordinate($city);

                $user = User::create([
                    'phone' => $phone,
                    'name' => "SYN_{$batch}_".str_pad((string) ($i + 1), 4, '0', STR_PAD_LEFT),
                    'password' => $passwordHash,
                    'verify_status' => 'approved',
                    'realname_verified' => true,
                    'disabled' => false,
                    'is_synthetic' => true,
                    'synthetic_batch' => $batch,
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
                ]);
                $created++;

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
        $this->line("with_answers=".($withAnswers ? 'true' : 'false'));
        $this->line('cities='.implode(',', $cities));
        $this->line("age_range={$minAge}-{$maxAge}");
        $this->line("phone_prefix={$phonePrefix}");
        $this->line("synthetic_password={$password}");

        return self::SUCCESS;
    }

    private function clearBatch(string $batch): int
    {
        return User::query()
            ->where('is_synthetic', true)
            ->where('synthetic_batch', $batch)
            ->delete();
    }

    private function nextPhone(string $prefix): string
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

        while (true) {
            $max = (10 ** $suffixLen) - 1;
            $phone = $normalized.str_pad((string) random_int(0, $max), $suffixLen, '0', STR_PAD_LEFT);
            $exists = User::query()->where('phone', $phone)->exists();
            if (!$exists) {
                return $phone;
            }
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

    private function randomBirthday(int $minAge, int $maxAge): string
    {
        $age = random_int($minAge, $maxAge);
        $start = now()->subYears($age + 1)->addDay();
        $end = now()->subYears($age);
        $days = max(1, $start->diffInDays($end));
        return $start->addDays(random_int(0, $days))->format('Y-m-d');
    }

    /**
     * @return array<string,mixed>
     */
    private function randomPersonalityVector(): array
    {
        return [
            'openness' => random_int(35, 95),
            'conscientiousness' => random_int(35, 95),
            'extraversion' => random_int(20, 95),
            'agreeableness' => random_int(30, 95),
            'neuroticism' => random_int(10, 90),
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
}
