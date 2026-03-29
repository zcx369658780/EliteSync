<?php

namespace App\Console\Commands;

use App\Models\AppEvent;
use App\Models\DatingMatch;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevCleanupCalibrationInjectedCommand extends Command
{
    protected $signature = 'app:dev:cleanup-calibration-injected
        {--days=30 : Lookback window in days}
        {--week-tag= : Optional week_tag filter}
        {--limit=500 : Max released matches to scan}
        {--dry-run : Only report counts, do not delete}';

    protected $description = 'Cleanup calibration-injected chat/events by marker and event type.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $weekTag = trim((string) $this->option('week-tag'));
        $limit = max(1, (int) $this->option('limit'));
        $dryRun = (bool) $this->option('dry-run');
        $markerPrefix = trim((string) config('matching.calibration_injector.message_marker_prefix', '[[calibration_injector]]'));
        if ($markerPrefix === '') {
            $markerPrefix = '[[calibration_injector]]';
        }
        $markerLike = $markerPrefix.'%';

        $since = now()->subDays($days);
        $q = DatingMatch::query()
            ->where('drop_released', true)
            ->where('created_at', '>=', $since)
            ->orderByDesc('id')
            ->limit($limit);
        if ($weekTag !== '') {
            $q->where('week_tag', $weekTag);
        }
        $matches = $q->get(['id', 'week_tag', 'user_a', 'user_b']);
        if ($matches->isEmpty()) {
            $this->warn('No released matches in range.');
            return self::SUCCESS;
        }

        $matchIds = $matches->pluck('id')->map(fn ($x) => (int) $x)->all();
        $roomIds = $matches->map(function ($m) {
            $a = (int) min((int) $m->user_a, (int) $m->user_b);
            $b = (int) max((int) $m->user_a, (int) $m->user_b);
            return $a.'_'.$b;
        })->unique()->values()->all();

        $chatCount = DB::table('chat_messages')
            ->whereIn('room_id', $roomIds)
            ->where('content', 'like', $markerLike)
            ->count();

        $eventCount = AppEvent::query()
            ->whereIn('match_id', $matchIds)
            ->where(function ($q) {
                $q->where('event_name', 'match_explanation_view_calibration')
                    ->orWhere('payload->source', 'calibration_injector');
            })
            ->count();

        $deletedChat = 0;
        $deletedEvents = 0;
        if (!$dryRun) {
            $deletedChat = DB::table('chat_messages')
                ->whereIn('room_id', $roomIds)
                ->where('content', 'like', $markerLike)
                ->delete();

            $deletedEvents = AppEvent::query()
                ->whereIn('match_id', $matchIds)
                ->where(function ($q) {
                    $q->where('event_name', 'match_explanation_view_calibration')
                        ->orWhere('payload->source', 'calibration_injector');
                })
                ->delete();
        }

        $this->info('Calibration-injected cleanup done.');
        $this->table(['metric', 'value'], [
            ['scanned_matches', (string) count($matchIds)],
            ['scanned_rooms', (string) count($roomIds)],
            ['chat_marked_found', (string) $chatCount],
            ['event_marked_found', (string) $eventCount],
            ['deleted_chat', (string) $deletedChat],
            ['deleted_events', (string) $deletedEvents],
            ['dry_run', $dryRun ? 'true' : 'false'],
        ]);

        return self::SUCCESS;
    }
}

