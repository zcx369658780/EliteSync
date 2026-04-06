<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Models\UserAstroProfile;
use App\Services\ZiweiCanonicalService;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevFillSyntheticZiweiCommand extends Command
{
    protected $signature = 'app:dev:fill-synthetic-ziwei
        {--batch= : Only process one synthetic_batch}
        {--overwrite=0 : Overwrite existing ziwei values (0|1)}
        {--limit=0 : Max users to process (0 means no limit)}
        {--dry-run : Preview only, do not write}';

    protected $description = 'Backfill synthetic users with Ziwei canonical profiles.';

    public function handle(ZiweiCanonicalService $ziwei): int
    {
        $allow = (bool) config('matching.debug.allow_synthetic_commands_in_production', false);
        if (!$allow && app()->environment('production')) {
            $this->error('Blocked in production: synthetic command is disabled. Set MATCHING_ALLOW_SYNTHETIC_COMMANDS_IN_PRODUCTION=true only for controlled operations.');
            return self::FAILURE;
        }

        $batch = trim((string) $this->option('batch'));
        $overwrite = in_array((string) $this->option('overwrite'), ['1', 'true', 'yes', 'on'], true);
        $dryRun = (bool) $this->option('dry-run');
        $limit = max(0, (int) $this->option('limit'));

        $q = User::query()
            ->where('is_synthetic', true)
            ->when($batch !== '', fn ($query) => $query->where('synthetic_batch', $batch))
            ->orderBy('id');
        if ($limit > 0) {
            $q->limit($limit);
        }
        $users = $q->get();
        if ($users->isEmpty()) {
            $this->warn('No synthetic users found for this filter.');
            return self::SUCCESS;
        }

        $this->line('users_selected='.$users->count());
        $this->line('overwrite='.($overwrite ? 'true' : 'false'));
        $this->line('dry_run='.($dryRun ? 'true' : 'false'));

        $done = 0;
        if (!$dryRun) {
            DB::beginTransaction();
        }

        try {
            foreach ($users as $user) {
                $profile = UserAstroProfile::query()->where('user_id', (int) $user->id)->first();
                if (!$profile) {
                    continue;
                }
                if (!$overwrite && is_array($profile->ziwei ?? null) && !empty($profile->ziwei)) {
                    continue;
                }

                $payload = [
                    'birthday' => optional($user->birthday)->format('Y-m-d'),
                    'birth_time' => (string) ($profile->birth_time ?? '12:00'),
                    'birth_place' => (string) ($profile->birth_place ?? ''),
                    'birth_lat' => $profile->birth_lat,
                    'birth_lng' => $profile->birth_lng,
                    'gender' => (string) ($user->gender ?? ''),
                    'user_id' => (int) $user->id,
                    'platform' => 'android',
                    'profile_version' => 0,
                    'notes' => (array) ($profile->notes ?? []),
                ];
                $normalized = $ziwei->canonicalize($payload);
                if (!$dryRun) {
                    $profile->forceFill([
                        'ziwei' => (array) ($normalized['ziwei'] ?? []),
                        'notes' => array_values(array_unique(array_merge(
                            (array) ($profile->notes ?? []),
                            (array) ($normalized['notes'] ?? [])
                        ))),
                    ])->save();
                }
                $done++;
            }

            if (!$dryRun) {
                DB::commit();
            }
        } catch (\Throwable $e) {
            if (!$dryRun) {
                DB::rollBack();
            }
            $this->error('fill synthetic ziwei failed: '.$e->getMessage());
            return self::FAILURE;
        }

        $this->info("ziwei_backfilled={$done}");
        return self::SUCCESS;
    }
}
