<?php

namespace App\Console\Commands;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;

class DevInjectCalibrationPositivesCommand extends Command
{
    protected $signature = 'app:dev:inject-calibration-positives
        {--days=30 : Lookback window in days}
        {--week-tag= : Optional week_tag filter}
        {--limit=200 : Max released matches to process}
        {--seed=20260329 : Random seed for stable replay}
        {--mutual-like-rate=0.35 : Target probability of mutual like}
        {--first-message-rate=0.30 : Target probability of first message}
        {--reply24h-rate=0.20 : Target probability of 24h reply (requires first message)}
        {--sustained7d-rate=0.10 : Target probability of sustained 7d interaction (requires first message)}
        {--explanation-view-rate=0.40 : Target probability of explanation view event}
        {--force : Force run even when injector is disabled by config}
        {--dry-run : Only count planned writes, do not persist}';

    protected $description = 'Inject positive interaction samples for calibration in test/staging environments.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $weekTag = trim((string) $this->option('week-tag'));
        $limit = max(1, (int) $this->option('limit'));
        $seed = (int) $this->option('seed');
        $dryRun = (bool) $this->option('dry-run');
        $force = (bool) $this->option('force');
        $injectorEnabled = (bool) config('matching.calibration_injector.enabled', false);
        $allowInProd = (bool) config('matching.calibration_injector.allow_in_production', false);
        $markerPrefix = trim((string) config('matching.calibration_injector.message_marker_prefix', '[[calibration_injector]]'));
        if ($markerPrefix === '') {
            $markerPrefix = '[[calibration_injector]]';
        }
        $marker = $markerPrefix . ' ';

        if (!$injectorEnabled && !$force) {
            $this->error('Calibration injector is disabled. Set MATCHING_CALIBRATION_INJECTOR_ENABLED=true or use --force.');
            return self::FAILURE;
        }
        if (app()->environment('production') && !$allowInProd) {
            $this->error('Blocked in production: MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION=true is required.');
            return self::FAILURE;
        }

        $rMutual = $this->clampRate((float) $this->option('mutual-like-rate'));
        $rFirst = $this->clampRate((float) $this->option('first-message-rate'));
        $rReply = $this->clampRate((float) $this->option('reply24h-rate'));
        $rSustained = $this->clampRate((float) $this->option('sustained7d-rate'));
        $rView = $this->clampRate((float) $this->option('explanation-view-rate'));

        $since = now()->subDays($days);
        $q = DatingMatch::query()
            ->where('drop_released', true)
            ->where('created_at', '>=', $since)
            ->orderByDesc('id')
            ->limit($limit);
        if ($weekTag !== '') {
            $q->where('week_tag', $weekTag);
        }
        $matches = $q->get();
        if ($matches->isEmpty()) {
            $this->warn('No released matches in range.');
            return self::SUCCESS;
        }

        $stats = [
            'processed' => 0,
            'set_mutual' => 0,
            'first_message' => 0,
            'reply_24h' => 0,
            'sustained_7d' => 0,
            'explanation_view' => 0,
        ];

        foreach ($matches as $m) {
            $stats['processed']++;
            $pair = $this->pairOrder((int) $m->user_a, (int) $m->user_b);
            $roomId = $this->roomId($pair['a'], $pair['b']);
            $createdAt = $m->created_at ?? now();

            $rngBase = $seed + ((int) $m->id * 131);
            $wantMutual = $this->sampleBySeed($rngBase + 1, $rMutual);
            $wantFirst = $this->sampleBySeed($rngBase + 2, $rFirst);
            $wantReply24h = $wantFirst && $this->sampleBySeed($rngBase + 3, $rReply);
            $wantSustained7d = $wantFirst && $this->sampleBySeed($rngBase + 4, $rSustained);
            $wantView = $this->sampleBySeed($rngBase + 5, $rView);

            if ($wantMutual && !((bool) $m->like_a && (bool) $m->like_b)) {
                $stats['set_mutual']++;
                if (!$dryRun) {
                    $m->forceFill(['like_a' => true, 'like_b' => true])->save();
                }
            }

            $first = ChatMessage::query()
                ->where('room_id', $roomId)
                ->where('created_at', '>=', $createdAt)
                ->orderBy('id')
                ->first(['id', 'sender_id', 'receiver_id', 'created_at']);

            if ($wantFirst && !$first) {
                $stats['first_message']++;
                if (!$dryRun) {
                    $at = $createdAt->copy()->addMinutes(5);
                    DB::table('chat_messages')->insert([
                        'room_id' => $roomId,
                        'sender_id' => $pair['a'],
                        'receiver_id' => $pair['b'],
                        'content' => $marker.'hi from calibration injector',
                        'is_read' => false,
                        'created_at' => $at,
                        'updated_at' => $at,
                    ]);
                    $first = ChatMessage::query()
                        ->where('room_id', $roomId)
                        ->where('created_at', '>=', $createdAt)
                        ->orderBy('id')
                        ->first(['id', 'sender_id', 'receiver_id', 'created_at']);
                }
            }

            if ($wantReply24h && $first) {
                $reply = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>', $first->created_at)
                    ->where('created_at', '<=', $first->created_at->copy()->addHours(24))
                    ->where('sender_id', '!=', (int) $first->sender_id)
                    ->first(['id']);
                if (!$reply) {
                    $stats['reply_24h']++;
                    if (!$dryRun) {
                        $at = $first->created_at->copy()->addHours(2);
                        DB::table('chat_messages')->insert([
                            'room_id' => $roomId,
                            'sender_id' => (int) $first->receiver_id,
                            'receiver_id' => (int) $first->sender_id,
                            'content' => $marker.'reply from calibration injector',
                            'is_read' => false,
                            'created_at' => $at,
                            'updated_at' => $at,
                        ]);
                    }
                }
            }

            if ($wantSustained7d && $first) {
                $msgs7d = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>=', $first->created_at)
                    ->where('created_at', '<=', $first->created_at->copy()->addDays(7))
                    ->get(['sender_id', 'created_at']);
                $senderCount = $msgs7d->pluck('sender_id')->unique()->count();
                $messageCount = $msgs7d->count();
                $activeDays = $msgs7d
                    ->map(fn ($x) => optional($x->created_at)->format('Y-m-d'))
                    ->filter()
                    ->unique()
                    ->count();

                $already = $senderCount >= 2 && ($messageCount >= 6 || $activeDays >= 3);
                if (!$already) {
                    $stats['sustained_7d']++;
                    if (!$dryRun) {
                        $schedule = [
                            [12, $pair['a'], $pair['b'], 'day1'],
                            [14, $pair['b'], $pair['a'], 'day1-reply'],
                            [26, $pair['a'], $pair['b'], 'day2'],
                            [28, $pair['b'], $pair['a'], 'day2-reply'],
                            [52, $pair['a'], $pair['b'], 'day3'],
                            [56, $pair['b'], $pair['a'], 'day3-reply'],
                        ];
                        foreach ($schedule as [$h, $s, $r, $txt]) {
                            $at = $first->created_at->copy()->addHours($h);
                            DB::table('chat_messages')->insert([
                                'room_id' => $roomId,
                                'sender_id' => $s,
                                'receiver_id' => $r,
                                'content' => $marker."calibration $txt",
                                'is_read' => false,
                                'created_at' => $at,
                                'updated_at' => $at,
                            ]);
                        }
                    }
                }
            }

            if ($wantView) {
                $exists = AppEvent::query()
                    ->where('event_name', 'match_explanation_view')
                    ->where('match_id', (int) $m->id)
                    ->exists();
                if (!$exists) {
                    $stats['explanation_view']++;
                    if (!$dryRun) {
                        AppEvent::create([
                            'event_name' => 'match_explanation_view_calibration',
                            'actor_user_id' => $pair['a'],
                            'target_user_id' => $pair['b'],
                            'match_id' => (int) $m->id,
                            'payload' => ['source' => 'calibration_injector'],
                        ]);
                    }
                }
            }
        }

        $this->info('Calibration positives injection done.');
        $this->table(['metric', 'value'], [
            ['processed', (string) $stats['processed']],
            ['set_mutual', (string) $stats['set_mutual']],
            ['first_message', (string) $stats['first_message']],
            ['reply_24h', (string) $stats['reply_24h']],
            ['sustained_7d', (string) $stats['sustained_7d']],
            ['explanation_view', (string) $stats['explanation_view']],
            ['dry_run', $dryRun ? 'true' : 'false'],
        ]);

        return self::SUCCESS;
    }

    private function clampRate(float $v): float
    {
        return max(0.0, min(1.0, $v));
    }

    private function sampleBySeed(int $seed, float $rate): bool
    {
        if ($rate <= 0.0) {
            return false;
        }
        if ($rate >= 1.0) {
            return true;
        }
        $hash = crc32((string) $seed);
        $u = ($hash % 10000) / 10000.0;
        return $u < $rate;
    }

    private function pairOrder(int $u1, int $u2): array
    {
        return $u1 < $u2
            ? ['a' => $u1, 'b' => $u2]
            : ['a' => $u2, 'b' => $u1];
    }

    private function roomId(int $a, int $b): string
    {
        return $a . '_' . $b;
    }
}
