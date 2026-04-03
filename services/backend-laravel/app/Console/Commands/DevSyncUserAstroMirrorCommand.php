<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\UserAstroMirrorService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevSyncUserAstroMirrorCommand extends Command
{
    protected $signature = 'app:dev:sync-user-astro-mirror
        {--batch= : Optional synthetic_batch filter}
        {--limit=0 : Max users to process (0 means no limit)}
        {--dry-run : Preview only, do not write}
        {--users-to-profiles=0 : Bootstrap missing user_astro_profiles from users.private_* (0|1)}
        {--include-ziwei=1 : Rebuild ziwei data when bootstrapping profiles (0|1)}';

    protected $description = 'Sync astro mirror fields on users from canonical user_astro_profiles.';

    public function handle(UserAstroMirrorService $mirror, ZiweiCanonicalService $ziwei): int
    {
        $dryRun = (bool) $this->option('dry-run');
        $limit = max(0, (int) $this->option('limit'));
        $batch = trim((string) $this->option('batch'));
        $bootstrap = in_array((string) $this->option('users-to-profiles'), ['1', 'true', 'yes', 'on'], true);
        $includeZiwei = in_array((string) $this->option('include-ziwei'), ['1', 'true', 'yes', 'on'], true);

        $q = User::query()
            ->when($batch !== '', function ($query) use ($batch) {
                $query->where('synthetic_batch', $batch);
            })
            ->orderBy('id');
        if ($limit > 0) {
            $q->limit($limit);
        }
        $users = $q->get();
        if ($users->isEmpty()) {
            $this->warn('No users found for this filter.');
            return self::SUCCESS;
        }

        $this->line('users_selected='.$users->count());
        $this->line('dry_run='.($dryRun ? 'true' : 'false'));
        $this->line('bootstrap_users_to_profiles='.($bootstrap ? 'true' : 'false'));
        $this->line('include_ziwei='.($includeZiwei ? 'true' : 'false'));

        $synced = 0;
        $bootstrapped = 0;

        if (!$dryRun) {
            DB::beginTransaction();
        }
        try {
            foreach ($users as $user) {
                $profile = UserAstroProfile::query()->where('user_id', (int) $user->id)->first();
                if (!$profile && $bootstrap) {
                    $chart = is_array($user->private_natal_chart) ? $user->private_natal_chart : [];
                    $sun = trim((string) ($user->public_zodiac_sign ?? ''));
                    $bazi = trim((string) ($user->private_bazi ?? ''));
                    $time = trim((string) data_get($chart, 'true_solar_time', ''));
                    if ($sun !== '' || $bazi !== '' || $time !== '' || !empty($chart)) {
                        if (!$dryRun) {
                            $profile = UserAstroProfile::query()->create([
                                'user_id' => (int) $user->id,
                                'birth_time' => preg_match('/^\d{2}:\d{2}$/', $time) ? $time : '12:00',
                                'birth_place' => $user->private_birth_place,
                                'birth_lat' => $user->private_birth_lat,
                                'birth_lng' => $user->private_birth_lng,
                                'sun_sign' => $sun !== '' ? $sun : '未知',
                                'moon_sign' => data_get($chart, 'moon_sign'),
                                'asc_sign' => data_get($chart, 'asc_sign'),
                                'bazi' => $bazi !== '' ? $bazi : null,
                                'true_solar_time' => $time !== '' ? $time : null,
                                'da_yun' => data_get($chart, 'da_yun', []),
                                'liu_nian' => data_get($chart, 'liu_nian', []),
                                'wu_xing' => data_get($chart, 'wu_xing', []),
                                'ziwei' => $includeZiwei
                                    ? (array) $ziwei->canonicalize([
                                        'birthday' => optional($user->birthday)->format('Y-m-d'),
                                        'birth_time' => preg_match('/^\d{2}:\d{2}$/', $time) ? $time : '12:00',
                                        'birth_place' => $user->private_birth_place,
                                        'birth_lat' => $user->private_birth_lat,
                                        'birth_lng' => $user->private_birth_lng,
                                        'gender' => (string) ($user->gender ?? ''),
                                        'user_id' => (int) $user->id,
                                        'platform' => 'android',
                                        'profile_version' => 0,
                                        'notes' => data_get($chart, 'notes', ['bootstrap_from_users_private']),
                                    ])['ziwei'] ?? []
                                    : [],
                                'notes' => data_get($chart, 'notes', ['bootstrap_from_users_private']),
                                'computed_at' => now(),
                            ]);
                        }
                        $bootstrapped++;
                    }
                }

                if ($profile) {
                    if (!$dryRun) {
                        $mirror->syncFromAstroProfile($user, $profile);
                    }
                    $synced++;
                }
            }

            if (!$dryRun) {
                DB::commit();
            }
        } catch (\Throwable $e) {
            if (!$dryRun) {
                DB::rollBack();
            }
            $this->error('sync astro mirror failed: '.$e->getMessage());
            return self::FAILURE;
        }

        $this->info("synced={$synced}");
        $this->line("bootstrapped_profiles={$bootstrapped}");
        return self::SUCCESS;
    }
}
