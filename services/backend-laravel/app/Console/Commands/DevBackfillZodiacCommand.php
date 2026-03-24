<?php

namespace App\Console\Commands;

use App\Models\User;
use App\Services\ChineseZodiacService;
use Illuminate\Console\Command;

class DevBackfillZodiacCommand extends Command
{
    protected $signature = 'app:dev:backfill-zodiac
        {--force : Recompute even if zodiac_animal already exists}
        {--dry-run : Print stats only, no write}
        {--batch-size=500 : Chunk size for update}';

    protected $description = 'Backfill users.zodiac_animal from birthday.';

    public function handle(ChineseZodiacService $zodiacService): int
    {
        $force = (bool) $this->option('force');
        $dryRun = (bool) $this->option('dry-run');
        $batchSize = max(100, (int) $this->option('batch-size'));

        $base = User::query()->whereNotNull('birthday');
        if (!$force) {
            $base->where(function ($q) {
                $q->whereNull('zodiac_animal')->orWhere('zodiac_animal', '');
            });
        }

        $total = (clone $base)->count();
        if ($total === 0) {
            $this->info('No users need zodiac backfill.');
            return self::SUCCESS;
        }

        $updated = 0;
        $scanned = 0;

        $base->orderBy('id')->chunkById($batchSize, function ($users) use ($zodiacService, $dryRun, &$updated, &$scanned) {
            /** @var \Illuminate\Support\Collection<int,\App\Models\User> $users */
            foreach ($users as $user) {
                $scanned++;
                $animal = $zodiacService->fromBirthdayString(optional($user->birthday)->format('Y-m-d'));
                if (!$animal) {
                    continue;
                }
                if ($dryRun) {
                    $updated++;
                    continue;
                }
                $affected = User::query()
                    ->where('id', $user->id)
                    ->update(['zodiac_animal' => $animal]);
                if ($affected > 0) {
                    $updated++;
                }
            }
        });

        $this->line("scanned={$scanned}");
        $this->line("updated={$updated}");
        $this->line('dry_run='.($dryRun ? 'true' : 'false'));
        $this->line('force='.($force ? 'true' : 'false'));

        return self::SUCCESS;
    }
}

