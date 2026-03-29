<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\LegacyClientBaziEngine;
use App\Services\LegacyInputWesternNatalEngine;
use App\Services\LunarPhpBaziEngine;
use App\Services\WesternNatalCanonicalService;
use Illuminate\Console\Command;

class DevAstroShadowCompareCommand extends Command
{
    protected $signature = 'app:dev:astro-shadow-compare
        {--limit=50 : Number of users to compare}
        {--user-ids= : Comma separated user ids}
        {--out=docs/devlogs/ASTRO_SHADOW_COMPARE.md : Markdown report output path}
        {--json=docs/devlogs/ASTRO_SHADOW_COMPARE.json : JSON report output path}
        {--only-mismatch : Show mismatches only in console table}';

    protected $description = 'Shadow compare bazi/western canonical output between legacy and current pipeline.';

    public function handle(): int
    {
        $limit = max(1, (int) $this->option('limit'));
        $onlyMismatch = (bool) $this->option('only-mismatch');
        $outMd = trim((string) $this->option('out'));
        $outJson = trim((string) $this->option('json'));

        $legacyBazi = app(LegacyClientBaziEngine::class);
        $lunarBazi = app(LunarPhpBaziEngine::class);
        $legacyWestern = app(LegacyInputWesternNatalEngine::class);
        $westernCanonical = app(WesternNatalCanonicalService::class);

        $query = User::query()
            ->whereNotNull('birthday')
            ->whereNotNull('gender')
            ->where('birthday', '!=', '')
            ->with('astroProfile')
            ->orderBy('id');

        $ids = $this->parseUserIds((string) $this->option('user-ids'));
        if (!empty($ids)) {
            $query->whereIn('id', $ids);
        } else {
            $query->limit($limit);
        }

        $users = $query->get();
        if ($users->isEmpty()) {
            $this->warn('No users matched for shadow compare.');
            return self::SUCCESS;
        }

        $rows = [];
        $detail = [];
        $dimensionCount = [
            'bazi_sun' => 0,
            'bazi_text' => 0,
            'bazi_wuxing' => 0,
            'western_sun' => 0,
            'western_moon' => 0,
            'western_asc' => 0,
            'western_precision' => 0,
            'western_engine' => 0,
            'western_confidence_major' => 0,
            'house_unsupported' => 0,
            'aspect_unsupported' => 0,
        ];
        $userDiffScore = [];
        $stat = [
            'total' => 0,
            'bazi_sun_diff' => 0,
            'bazi_text_diff' => 0,
            'bazi_wuxing_diff' => 0,
            'western_sun_diff' => 0,
            'western_moon_diff' => 0,
            'western_asc_diff' => 0,
            'western_precision_diff' => 0,
            'western_engine_diff' => 0,
            'western_confidence_major_diff' => 0, // >0.2
            'house_unsupported' => 0,
            'aspect_unsupported' => 0,
            'any_diff' => 0,
        ];

        foreach ($users as $user) {
            $payload = $this->buildPayload($user);

            $oldBazi = $legacyBazi->canonicalize($payload);
            $newBazi = $lunarBazi->canonicalize($payload);
            $oldWestern = $legacyWestern->compute($payload);
            $newWestern = $westernCanonical->compute(array_merge($payload, [
                'user_id' => (int) $user->id,
                'platform' => 'android',
                'profile_version' => 0,
            ]));

            $baziSunDiff = $this->neq($oldBazi['sun_sign'] ?? '', $newBazi['sun_sign'] ?? '');
            $baziTextDiff = $this->neq($oldBazi['bazi'] ?? '', $newBazi['bazi'] ?? '');
            $baziWuxingDiff = json_encode((array) ($oldBazi['wu_xing'] ?? []), JSON_UNESCAPED_UNICODE)
                !== json_encode((array) ($newBazi['wu_xing'] ?? []), JSON_UNESCAPED_UNICODE);

            $westernSunDiff = $this->neq($oldWestern['sun_sign'] ?? '', $newWestern['sun_sign'] ?? '');
            $westernMoonDiff = $this->neq($oldWestern['moon_sign'] ?? '', $newWestern['moon_sign'] ?? '');
            $westernAscDiff = $this->neq($oldWestern['asc_sign'] ?? '', $newWestern['asc_sign'] ?? '');
            $westernPrecisionDiff = $this->neq($oldWestern['precision'] ?? '', $newWestern['precision'] ?? '');
            $westernEngineDiff = $this->neq($oldWestern['engine'] ?? '', $newWestern['engine'] ?? '');
            $oldConf = (float) ($oldWestern['confidence'] ?? 0.0);
            $newConf = (float) ($newWestern['confidence'] ?? 0.0);
            $westernConfidenceMajorDiff = abs($oldConf - $newConf) > 0.2;

            $profile = $user->astroProfile;
            $chart = is_array($user->private_natal_chart) ? $user->private_natal_chart : [];
            $houseUnsupported = !is_array($chart['houses'] ?? null);
            $aspectUnsupported = !is_array($chart['major_aspects'] ?? null);

            $anyDiff = $baziSunDiff || $baziTextDiff || $baziWuxingDiff ||
                $westernSunDiff || $westernMoonDiff || $westernAscDiff ||
                $westernPrecisionDiff || $westernEngineDiff || $westernConfidenceMajorDiff;

            $stat['total']++;
            $stat['bazi_sun_diff'] += $baziSunDiff ? 1 : 0;
            $stat['bazi_text_diff'] += $baziTextDiff ? 1 : 0;
            $stat['bazi_wuxing_diff'] += $baziWuxingDiff ? 1 : 0;
            $stat['western_sun_diff'] += $westernSunDiff ? 1 : 0;
            $stat['western_moon_diff'] += $westernMoonDiff ? 1 : 0;
            $stat['western_asc_diff'] += $westernAscDiff ? 1 : 0;
            $stat['western_precision_diff'] += $westernPrecisionDiff ? 1 : 0;
            $stat['western_engine_diff'] += $westernEngineDiff ? 1 : 0;
            $stat['western_confidence_major_diff'] += $westernConfidenceMajorDiff ? 1 : 0;
            $stat['house_unsupported'] += $houseUnsupported ? 1 : 0;
            $stat['aspect_unsupported'] += $aspectUnsupported ? 1 : 0;
            $stat['any_diff'] += $anyDiff ? 1 : 0;
            $dimensionCount['bazi_sun'] += $baziSunDiff ? 1 : 0;
            $dimensionCount['bazi_text'] += $baziTextDiff ? 1 : 0;
            $dimensionCount['bazi_wuxing'] += $baziWuxingDiff ? 1 : 0;
            $dimensionCount['western_sun'] += $westernSunDiff ? 1 : 0;
            $dimensionCount['western_moon'] += $westernMoonDiff ? 1 : 0;
            $dimensionCount['western_asc'] += $westernAscDiff ? 1 : 0;
            $dimensionCount['western_precision'] += $westernPrecisionDiff ? 1 : 0;
            $dimensionCount['western_engine'] += $westernEngineDiff ? 1 : 0;
            $dimensionCount['western_confidence_major'] += $westernConfidenceMajorDiff ? 1 : 0;
            $dimensionCount['house_unsupported'] += $houseUnsupported ? 1 : 0;
            $dimensionCount['aspect_unsupported'] += $aspectUnsupported ? 1 : 0;

            $userDiffScore[(int) $user->id] = array_sum([
                $baziSunDiff ? 1 : 0,
                $baziTextDiff ? 1 : 0,
                $baziWuxingDiff ? 1 : 0,
                $westernSunDiff ? 1 : 0,
                $westernMoonDiff ? 1 : 0,
                $westernAscDiff ? 1 : 0,
                $westernPrecisionDiff ? 1 : 0,
                $westernEngineDiff ? 1 : 0,
                $westernConfidenceMajorDiff ? 1 : 0,
                $houseUnsupported ? 1 : 0,
                $aspectUnsupported ? 1 : 0,
            ]);

            $rows[] = [
                'uid' => (string) $user->id,
                'bazi_diff' => ($baziSunDiff || $baziTextDiff || $baziWuxingDiff) ? 'Y' : 'N',
                'west_diff' => ($westernSunDiff || $westernMoonDiff || $westernAscDiff || $westernPrecisionDiff || $westernEngineDiff || $westernConfidenceMajorDiff) ? 'Y' : 'N',
                'house' => $houseUnsupported ? 'N/A' : 'OK',
                'aspect' => $aspectUnsupported ? 'N/A' : 'OK',
                'rollout' => (string) ($newWestern['rollout_reason'] ?? 'n/a'),
                'flag' => $anyDiff ? 'DIFF' : 'OK',
            ];

            $detail[] = [
                'user_id' => (int) $user->id,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'gender' => (string) $user->gender,
                'astro_profile_exists' => $profile !== null,
                'bazi' => [
                    'legacy' => [
                        'sun_sign' => (string) ($oldBazi['sun_sign'] ?? ''),
                        'bazi' => (string) ($oldBazi['bazi'] ?? ''),
                        'wu_xing' => (array) ($oldBazi['wu_xing'] ?? []),
                        'confidence' => (float) ($oldBazi['confidence'] ?? 0.0),
                    ],
                    'candidate' => [
                        'sun_sign' => (string) ($newBazi['sun_sign'] ?? ''),
                        'bazi' => (string) ($newBazi['bazi'] ?? ''),
                        'wu_xing' => (array) ($newBazi['wu_xing'] ?? []),
                        'confidence' => (float) ($newBazi['confidence'] ?? 0.0),
                    ],
                    'diff' => [
                        'sun_sign' => $baziSunDiff,
                        'bazi_text' => $baziTextDiff,
                        'wu_xing' => $baziWuxingDiff,
                    ],
                ],
                'western' => [
                    'legacy' => [
                        'engine' => (string) ($oldWestern['engine'] ?? ''),
                        'precision' => (string) ($oldWestern['precision'] ?? ''),
                        'sun_sign' => (string) ($oldWestern['sun_sign'] ?? ''),
                        'moon_sign' => (string) ($oldWestern['moon_sign'] ?? ''),
                        'asc_sign' => (string) ($oldWestern['asc_sign'] ?? ''),
                        'confidence' => $oldConf,
                    ],
                    'candidate' => [
                        'engine' => (string) ($newWestern['engine'] ?? ''),
                        'precision' => (string) ($newWestern['precision'] ?? ''),
                        'sun_sign' => (string) ($newWestern['sun_sign'] ?? ''),
                        'moon_sign' => (string) ($newWestern['moon_sign'] ?? ''),
                        'asc_sign' => (string) ($newWestern['asc_sign'] ?? ''),
                        'confidence' => $newConf,
                        'rollout_enabled' => (bool) ($newWestern['rollout_enabled'] ?? false),
                        'rollout_reason' => (string) ($newWestern['rollout_reason'] ?? ''),
                    ],
                    'diff' => [
                        'sun_sign' => $westernSunDiff,
                        'moon_sign' => $westernMoonDiff,
                        'asc_sign' => $westernAscDiff,
                        'precision' => $westernPrecisionDiff,
                        'engine' => $westernEngineDiff,
                        'confidence_major' => $westernConfidenceMajorDiff,
                    ],
                    'house_supported' => !$houseUnsupported,
                    'aspect_supported' => !$aspectUnsupported,
                ],
            ];
        }

        $diffRate = $this->pct($stat['any_diff'], $stat['total']);
        $this->info(sprintf(
            'Shadow compared %d users, any_diff=%d (%.2f%%)',
            $stat['total'],
            $stat['any_diff'],
            $diffRate
        ));

        $displayRows = $onlyMismatch
            ? array_values(array_filter($rows, fn ($r) => ($r['flag'] ?? '') === 'DIFF'))
            : $rows;
        if (!empty($displayRows)) {
            $this->table(array_keys($displayRows[0]), $displayRows);
        }

        $report = [
            'generated_at' => now()->toIso8601String(),
            'summary' => [
                ...$stat,
                'any_diff_rate_pct' => $diffRate,
                'house_unsupported_rate_pct' => $this->pct($stat['house_unsupported'], $stat['total']),
                'aspect_unsupported_rate_pct' => $this->pct($stat['aspect_unsupported'], $stat['total']),
                'top_diff_dimensions' => $this->topDiffDimensions($dimensionCount, 5),
                'top_diff_users' => $this->topDiffUsers($userDiffScore, 10),
            ],
            'detail' => $detail,
        ];

        $this->writeReports($outMd, $outJson, $report);
        $this->info('Reports written: '.$outMd.' / '.$outJson);

        return self::SUCCESS;
    }

    /**
     * @return array<int,int>
     */
    private function parseUserIds(string $value): array
    {
        $parts = array_map('trim', explode(',', $value));
        return array_values(array_filter(array_map('intval', $parts), fn ($v) => $v > 0));
    }

    private function pct(int $num, int $den): float
    {
        if ($den <= 0) {
            return 0.0;
        }
        return round(($num * 100.0) / $den, 2);
    }

    /**
     * @param mixed $a
     * @param mixed $b
     */
    private function neq(mixed $a, mixed $b): bool
    {
        return trim((string) $a) !== trim((string) $b);
    }

    /**
     * @param User $user
     * @return array<string,mixed>
     */
    private function buildPayload(User $user): array
    {
        /** @var UserAstroProfile|null $profile */
        $profile = $user->astroProfile;
        $chart = is_array($user->private_natal_chart) ? $user->private_natal_chart : [];

        $birthTime = trim((string) ($profile?->birth_time ?? $chart['true_solar_time'] ?? ''));
        if ($birthTime !== '' && str_contains($birthTime, ' ')) {
            $birthTime = substr($birthTime, -5);
        }
        if (!preg_match('/^\d{2}:\d{2}$/', $birthTime)) {
            $birthTime = '12:00';
        }

        return [
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $birthTime,
            'birth_lat' => $profile?->birth_lat ?? ($user->private_birth_lat ?? null),
            'birth_lng' => $profile?->birth_lng ?? ($user->private_birth_lng ?? null),
            'gender' => (string) $user->gender,
            'sun_sign' => (string) ($profile?->sun_sign ?? $user->public_zodiac_sign ?? ''),
            'moon_sign' => $profile?->moon_sign ?? ($chart['moon_sign'] ?? null),
            'asc_sign' => $profile?->asc_sign ?? ($chart['asc_sign'] ?? null),
            'bazi' => (string) ($profile?->bazi ?? $user->private_bazi ?? ''),
            'true_solar_time' => $profile?->true_solar_time ?? ($chart['true_solar_time'] ?? null),
            'da_yun' => $profile?->da_yun ?? ($chart['da_yun'] ?? []),
            'liu_nian' => $profile?->liu_nian ?? ($chart['liu_nian'] ?? []),
            'wu_xing' => $profile?->wu_xing ?? ($chart['wu_xing'] ?? []),
        ];
    }

    /**
     * @param array<string,mixed> $report
     */
    private function writeReports(string $mdPath, string $jsonPath, array $report): void
    {
        $mdAbs = base_path(trim($mdPath, '\\/'));
        $jsonAbs = base_path(trim($jsonPath, '\\/'));
        @mkdir(dirname($mdAbs), 0777, true);
        @mkdir(dirname($jsonAbs), 0777, true);

        file_put_contents($jsonAbs, json_encode($report, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));

        $s = (array) ($report['summary'] ?? []);
        $md = [];
        $md[] = '# Astro Shadow Compare Report';
        $md[] = '';
        $md[] = '- generated_at: '.($report['generated_at'] ?? '');
        $md[] = '- total: '.($s['total'] ?? 0);
        $md[] = '- any_diff: '.($s['any_diff'] ?? 0).' ('.($s['any_diff_rate_pct'] ?? 0).'%)';
        $md[] = '- bazi diff (sun/text/wuxing): '
            .($s['bazi_sun_diff'] ?? 0).'/'
            .($s['bazi_text_diff'] ?? 0).'/'
            .($s['bazi_wuxing_diff'] ?? 0);
        $md[] = '- western diff (sun/moon/asc/precision/engine/conf_major): '
            .($s['western_sun_diff'] ?? 0).'/'
            .($s['western_moon_diff'] ?? 0).'/'
            .($s['western_asc_diff'] ?? 0).'/'
            .($s['western_precision_diff'] ?? 0).'/'
            .($s['western_engine_diff'] ?? 0).'/'
            .($s['western_confidence_major_diff'] ?? 0);
        $md[] = '- unsupported house/aspect: '
            .($s['house_unsupported'] ?? 0).' ('.($s['house_unsupported_rate_pct'] ?? 0).'%)/'
            .($s['aspect_unsupported'] ?? 0).' ('.($s['aspect_unsupported_rate_pct'] ?? 0).'%)';
        $md[] = '';
        $md[] = '## Top Diff Dimensions';
        foreach ((array) ($s['top_diff_dimensions'] ?? []) as $row) {
            $md[] = '- '.(string) ($row['dimension'] ?? '').': '.(int) ($row['count'] ?? 0);
        }
        $md[] = '';
        $md[] = '## Top Diff Users';
        foreach ((array) ($s['top_diff_users'] ?? []) as $row) {
            $md[] = '- user '.(int) ($row['user_id'] ?? 0).': '.(int) ($row['diff_score'] ?? 0);
        }
        $md[] = '';
        $md[] = '## Notes';
        $md[] = '- `house_unsupported` and `aspect_unsupported` means canonical house/aspect engine is not wired yet.';
        $md[] = '- JSON detail contains per-user old/new outputs and diff flags.';
        $md[] = '';
        file_put_contents($mdAbs, implode(PHP_EOL, $md));
    }

    /**
     * @param array<string,int> $dimensionCount
     * @return array<int,array{dimension:string,count:int}>
     */
    private function topDiffDimensions(array $dimensionCount, int $limit): array
    {
        arsort($dimensionCount);
        $out = [];
        foreach (array_slice($dimensionCount, 0, $limit, true) as $k => $v) {
            $out[] = ['dimension' => (string) $k, 'count' => (int) $v];
        }
        return $out;
    }

    /**
     * @param array<int,int> $userDiffScore
     * @return array<int,array{user_id:int,diff_score:int}>
     */
    private function topDiffUsers(array $userDiffScore, int $limit): array
    {
        arsort($userDiffScore);
        $out = [];
        foreach (array_slice($userDiffScore, 0, $limit, true) as $uid => $score) {
            $out[] = ['user_id' => (int) $uid, 'diff_score' => (int) $score];
        }
        return $out;
    }
}
