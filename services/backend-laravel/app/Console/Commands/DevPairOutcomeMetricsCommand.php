<?php

namespace App\Console\Commands;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use Illuminate\Console\Command;

class DevPairOutcomeMetricsCommand extends Command
{
    protected $signature = 'app:dev:pair-outcome-metrics
        {--days=30 : Lookback window in days}
        {--week-tag= : Optional week_tag filter}
        {--out=docs/devlogs/PAIR_OUTCOME_METRICS.md : Markdown output path}
        {--json=docs/devlogs/PAIR_OUTCOME_METRICS.json : JSON output path}
        {--include-calibration-injected : Include calibration-injected chat/events in metrics}
        {--limit=0 : Optional latest match limit (0 means no limit)}';

    protected $description = 'Compute pair outcome metrics: mutual-like, first message, 24h reply, 7d sustained interaction, explanation-view.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $weekTag = trim((string) $this->option('week-tag'));
        $limit = max(0, (int) $this->option('limit'));
        $includeInjected = (bool) $this->option('include-calibration-injected')
            || (bool) config('matching.calibration_injector.include_in_metrics_default', false);
        $markerPrefix = trim((string) config('matching.calibration_injector.message_marker_prefix', '[[calibration_injector]]'));
        if ($markerPrefix === '') {
            $markerPrefix = '[[calibration_injector]]';
        }
        $markerLike = $markerPrefix.'%';
        $outMd = trim((string) $this->option('out'));
        $outJson = trim((string) $this->option('json'));
        $since = now()->subDays($days);

        $q = DatingMatch::query()
            ->where('drop_released', true)
            ->where('created_at', '>=', $since)
            ->orderByDesc('id');
        if ($weekTag !== '') {
            $q->where('week_tag', $weekTag);
        }
        if ($limit > 0) {
            $q->limit($limit);
        }

        $matches = $q->get();
        if ($matches->isEmpty()) {
            $this->warn('No released matches in range.');
            return self::SUCCESS;
        }

        $summary = [
            'total_pairs' => 0,
            'mutual_like_pairs' => 0,
            'first_message_pairs' => 0,
            'reply_24h_pairs' => 0,
            'sustained_7d_pairs' => 0,
            'explanation_view_pairs' => 0,
        ];
        $detail = [];

        foreach ($matches as $m) {
            $summary['total_pairs']++;
            $pair = $this->pairOrder((int) $m->user_a, (int) $m->user_b);
            $roomId = $this->roomId($pair['a'], $pair['b']);
            $createdAt = $m->created_at ?? now();

            $mutual = (bool) $m->like_a && (bool) $m->like_b;
            if ($mutual) {
                $summary['mutual_like_pairs']++;
            }

            $firstMsgQ = ChatMessage::query()
                ->where('room_id', $roomId)
                ->where('created_at', '>=', $createdAt);
            if (!$includeInjected) {
                $firstMsgQ->where(function ($qq) use ($markerLike) {
                    $qq->whereNull('content')->orWhere('content', 'not like', $markerLike);
                });
            }
            $firstMsg = $firstMsgQ->orderBy('id')->first(['id', 'sender_id', 'receiver_id', 'created_at']);
            $hasFirstMessage = $firstMsg !== null;
            if ($hasFirstMessage) {
                $summary['first_message_pairs']++;
            }

            $reply24h = false;
            if ($firstMsg) {
                $replyQ = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>', $firstMsg->created_at)
                    ->where('created_at', '<=', $firstMsg->created_at->copy()->addHours(24))
                    ->where('sender_id', '!=', (int) $firstMsg->sender_id);
                if (!$includeInjected) {
                    $replyQ->where(function ($qq) use ($markerLike) {
                        $qq->whereNull('content')->orWhere('content', 'not like', $markerLike);
                    });
                }
                $reply = $replyQ->orderBy('id')->first(['id']);
                $reply24h = $reply !== null;
            }
            if ($reply24h) {
                $summary['reply_24h_pairs']++;
            }

            $sustained7d = false;
            if ($firstMsg) {
                $msgs7dQ = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>=', $firstMsg->created_at)
                    ->where('created_at', '<=', $firstMsg->created_at->copy()->addDays(7));
                if (!$includeInjected) {
                    $msgs7dQ->where(function ($qq) use ($markerLike) {
                        $qq->whereNull('content')->orWhere('content', 'not like', $markerLike);
                    });
                }
                $msgs7d = $msgs7dQ->get(['sender_id', 'created_at']);
                $senderCount = $msgs7d->pluck('sender_id')->unique()->count();
                $messageCount = $msgs7d->count();
                $activeDays = $msgs7d
                    ->map(fn ($x) => optional($x->created_at)->format('Y-m-d'))
                    ->filter()
                    ->unique()
                    ->count();
                // Rule: both sides sent message, and either >=6 msgs or >=3 active days.
                $sustained7d = $senderCount >= 2 && ($messageCount >= 6 || $activeDays >= 3);
            }
            if ($sustained7d) {
                $summary['sustained_7d_pairs']++;
            }

            $eventNames = $includeInjected
                ? ['match_explanation_view', 'match_explanation_view_calibration']
                : ['match_explanation_view'];
            $explanationViewed = AppEvent::query()
                ->whereIn('event_name', $eventNames)
                ->where('match_id', (int) $m->id)
                ->where('created_at', '>=', $createdAt)
                ->exists();
            if ($explanationViewed) {
                $summary['explanation_view_pairs']++;
            }

            $detail[] = [
                'match_id' => (int) $m->id,
                'week_tag' => (string) ($m->week_tag ?? ''),
                'user_a' => $pair['a'],
                'user_b' => $pair['b'],
                'mutual_like' => $mutual,
                'first_message' => $hasFirstMessage,
                'reply_24h' => $reply24h,
                'sustained_7d' => $sustained7d,
                'explanation_view' => $explanationViewed,
            ];
        }

        $report = [
            'generated_at' => now()->toIso8601String(),
            'window' => [
                'days' => $days,
                'week_tag' => $weekTag,
                'since' => $since->toIso8601String(),
                'limit' => $limit,
                'include_calibration_injected' => $includeInjected,
            ],
            'summary' => $this->withRates($summary),
            'detail' => $detail,
        ];

        $this->writeReports($outMd, $outJson, $report);
        $this->info(sprintf(
            'Pairs=%d, mutual=%d, first_msg=%d, reply24h=%d, sustained7d=%d, explanation_view=%d',
            $summary['total_pairs'],
            $summary['mutual_like_pairs'],
            $summary['first_message_pairs'],
            $summary['reply_24h_pairs'],
            $summary['sustained_7d_pairs'],
            $summary['explanation_view_pairs'],
        ));
        $this->info('Reports written: '.$outMd.' / '.$outJson);
        return self::SUCCESS;
    }

    /**
     * @return array{a:int,b:int}
     */
    private function pairOrder(int $a, int $b): array
    {
        return $a < $b ? ['a' => $a, 'b' => $b] : ['a' => $b, 'b' => $a];
    }

    private function roomId(int $a, int $b): string
    {
        return $a < $b ? "{$a}_{$b}" : "{$b}_{$a}";
    }

    /**
     * @param array<string,int> $summary
     * @return array<string,mixed>
     */
    private function withRates(array $summary): array
    {
        $total = max(1, (int) ($summary['total_pairs'] ?? 0));
        $out = $summary;
        $out['mutual_like_rate_pct'] = round(($summary['mutual_like_pairs'] * 100.0) / $total, 2);
        $out['first_message_rate_pct'] = round(($summary['first_message_pairs'] * 100.0) / $total, 2);
        $out['reply_24h_rate_pct'] = round(($summary['reply_24h_pairs'] * 100.0) / $total, 2);
        $out['sustained_7d_rate_pct'] = round(($summary['sustained_7d_pairs'] * 100.0) / $total, 2);
        $out['explanation_view_rate_pct'] = round(($summary['explanation_view_pairs'] * 100.0) / $total, 2);
        return $out;
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
        $w = (array) ($report['window'] ?? []);
        $md = [];
        $md[] = '# Pair Outcome Metrics';
        $md[] = '';
        $md[] = '- generated_at: '.($report['generated_at'] ?? '');
        $md[] = '- window_days: '.($w['days'] ?? '');
        $md[] = '- week_tag: '.($w['week_tag'] ?? '');
        $md[] = '- include_calibration_injected: '.(($w['include_calibration_injected'] ?? false) ? 'true' : 'false');
        $md[] = '- total_pairs: '.($s['total_pairs'] ?? 0);
        $md[] = '';
        $md[] = '## Conversion Funnel';
        $md[] = '- mutual_like: '.($s['mutual_like_pairs'] ?? 0).' ('.($s['mutual_like_rate_pct'] ?? 0).'%)';
        $md[] = '- first_message: '.($s['first_message_pairs'] ?? 0).' ('.($s['first_message_rate_pct'] ?? 0).'%)';
        $md[] = '- reply_24h: '.($s['reply_24h_pairs'] ?? 0).' ('.($s['reply_24h_rate_pct'] ?? 0).'%)';
        $md[] = '- sustained_7d: '.($s['sustained_7d_pairs'] ?? 0).' ('.($s['sustained_7d_rate_pct'] ?? 0).'%)';
        $md[] = '- explanation_view: '.($s['explanation_view_pairs'] ?? 0).' ('.($s['explanation_view_rate_pct'] ?? 0).'%)';
        $md[] = '';
        $md[] = '## Notes';
        $md[] = '- sustained_7d rule: both users participated, and >=6 messages or >=3 active days in first 7 days after first message.';
        $md[] = '- explanation_view based on app_event `match_explanation_view`.';
        $md[] = '';
        file_put_contents($mdAbs, implode(PHP_EOL, $md));
    }
}
