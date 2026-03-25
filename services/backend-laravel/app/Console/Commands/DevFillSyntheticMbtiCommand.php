<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevFillSyntheticMbtiCommand extends Command
{
    protected $signature = 'app:dev:fill-synthetic-mbti
        {--batch= : Only process one synthetic_batch}
        {--overwrite=0 : Overwrite existing MBTI values (0|1)}
        {--limit=0 : Max users to process (0 means no limit)}
        {--dry-run : Preview only, do not write}
        {--seed= : Optional mt_srand seed for reproducible random}';

    protected $description = 'Backfill synthetic users with random MBTI values.';

    /** @var array<int,string> */
    private array $mbtiPool = [
        'INTJ', 'INTP', 'ENTJ', 'ENTP',
        'INFJ', 'INFP', 'ENFJ', 'ENFP',
        'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
        'ISTP', 'ISFP', 'ESTP', 'ESFP',
    ];

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

    public function handle(): int
    {
        if (!$this->ensureSyntheticOpsAllowed()) {
            return self::FAILURE;
        }

        $seed = $this->option('seed');
        if ($seed !== null && $seed !== '') {
            mt_srand((int) $seed);
        }

        $overwrite = in_array((string) $this->option('overwrite'), ['1', 'true', 'yes', 'on'], true);
        $dryRun = (bool) $this->option('dry-run');
        $limit = max(0, (int) $this->option('limit'));
        $batch = trim((string) $this->option('batch'));

        $q = User::query()
            ->where('is_synthetic', true)
            ->when($batch !== '', function ($query) use ($batch) {
                $query->where('synthetic_batch', $batch);
            });

        if (!$overwrite) {
            $q->where(function ($qq) {
                $qq->whereNull('public_mbti')
                    ->orWhere('public_mbti', '');
            });
        }

        if ($limit > 0) {
            $q->limit($limit);
        }

        $users = $q->orderBy('id')->get(['id', 'public_mbti']);
        if ($users->isEmpty()) {
            $this->warn('No synthetic users found for this filter.');
            return self::SUCCESS;
        }

        $this->line('users_selected='.$users->count());
        $this->line('dry_run='.($dryRun ? 'true' : 'false'));
        $this->line('overwrite='.($overwrite ? 'true' : 'false'));
        if ($batch !== '') {
            $this->line('batch='.$batch);
        }

        $updated = 0;
        $dist = [];
        foreach ($this->mbtiPool as $t) {
            $dist[$t] = 0;
        }

        if (!$dryRun) {
            DB::beginTransaction();
        }
        try {
            foreach ($users as $u) {
                $mbti = $this->pickMbti((int) $u->id);
                $dist[$mbti] = (int) ($dist[$mbti] ?? 0) + 1;
                $updated++;

                if (!$dryRun) {
                    $u->forceFill(['public_mbti' => $mbti])->save();
                }
            }

            if (!$dryRun) {
                DB::commit();
            }
        } catch (\Throwable $e) {
            if (!$dryRun) {
                DB::rollBack();
            }
            $this->error('fill synthetic mbti failed: '.$e->getMessage());
            return self::FAILURE;
        }

        $this->info("updated={$updated}");
        $top = collect($dist)->filter(fn ($v) => $v > 0)->sortDesc();
        if ($top->isNotEmpty()) {
            $this->line('distribution='.json_encode($top->all(), JSON_UNESCAPED_UNICODE));
        }

        return self::SUCCESS;
    }

    private function pickMbti(int $seed): string
    {
        $idx = abs((int) (($seed * 1103515245 + 12345) & 0x7fffffff)) % count($this->mbtiPool);
        return $this->mbtiPool[$idx];
    }
}
