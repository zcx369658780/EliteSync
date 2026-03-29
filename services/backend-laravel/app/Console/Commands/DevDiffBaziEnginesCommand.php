<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\LegacyClientBaziEngine;
use App\Services\LunarPhpBaziEngine;
use Illuminate\Console\Command;

class DevDiffBaziEnginesCommand extends Command
{
    protected $signature = 'app:dev:diff-bazi-engines
        {--limit=50 : Number of users to compare}
        {--only-mismatch : Show mismatches only}';

    protected $description = 'Compare legacy client bazi canonical output with lunar-php canonical output for sampled users.';

    public function handle(): int
    {
        $limit = max(1, (int) $this->option('limit'));
        $onlyMismatch = (bool) $this->option('only-mismatch');

        $legacy = app(LegacyClientBaziEngine::class);
        $lunar = app(LunarPhpBaziEngine::class);

        $users = User::query()
            ->whereNotNull('birthday')
            ->whereNotNull('gender')
            ->where('birthday', '!=', '')
            ->orderBy('id')
            ->limit($limit)
            ->get(['id', 'birthday', 'gender', 'public_zodiac_sign', 'private_natal_chart']);

        if ($users->isEmpty()) {
            $this->warn('No users with birthday/gender found.');
            return self::SUCCESS;
        }

        $rows = [];
        $mismatch = 0;
        foreach ($users as $u) {
            $chart = is_array($u->private_natal_chart) ? $u->private_natal_chart : [];
            $birthTime = trim((string) ($chart['true_solar_time'] ?? ''));
            if ($birthTime !== '' && str_contains($birthTime, ' ')) {
                $birthTime = substr($birthTime, -5);
            }
            if (!preg_match('/^\d{2}:\d{2}$/', $birthTime)) {
                $birthTime = '12:00';
            }
            $payload = [
                'birthday' => optional($u->birthday)->format('Y-m-d'),
                'birth_time' => $birthTime,
                'gender' => (string) $u->gender,
                'sun_sign' => (string) ($u->public_zodiac_sign ?? ''),
                'moon_sign' => $chart['moon_sign'] ?? null,
                'asc_sign' => $chart['asc_sign'] ?? null,
                'bazi' => (string) ($u->private_bazi ?? ''),
            ];
            $old = $legacy->canonicalize($payload);
            $new = $lunar->canonicalize($payload);

            $sameSun = (string) ($old['sun_sign'] ?? '') === (string) ($new['sun_sign'] ?? '');
            $sameBazi = (string) ($old['bazi'] ?? '') === (string) ($new['bazi'] ?? '');
            $sameWuXing = json_encode((array) ($old['wu_xing'] ?? []), JSON_UNESCAPED_UNICODE)
                === json_encode((array) ($new['wu_xing'] ?? []), JSON_UNESCAPED_UNICODE);
            $isMismatch = !($sameSun && $sameBazi && $sameWuXing);
            if ($isMismatch) {
                $mismatch++;
            }
            if ($onlyMismatch && !$isMismatch) {
                continue;
            }

            $rows[] = [
                'uid' => (string) $u->id,
                'sun(old/new)' => ((string) ($old['sun_sign'] ?? '')).'/'.((string) ($new['sun_sign'] ?? '')),
                'bazi_same' => $sameBazi ? 'Y' : 'N',
                'wu_xing_same' => $sameWuXing ? 'Y' : 'N',
                'new_conf' => (string) round((float) ($new['confidence'] ?? 0.0), 2),
                'flag' => $isMismatch ? 'DIFF' : 'OK',
            ];
        }

        $this->info(sprintf(
            'Compared %d users, mismatches=%d (%.2f%%)',
            $users->count(),
            $mismatch,
            ($mismatch / max(1, $users->count())) * 100.0
        ));
        if (!empty($rows)) {
            $this->table(array_keys($rows[0]), $rows);
        }

        return self::SUCCESS;
    }
}

