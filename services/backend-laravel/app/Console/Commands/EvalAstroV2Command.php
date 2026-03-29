<?php

namespace App\Console\Commands;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class EvalAstroV2Command extends Command
{
    protected $signature = 'app:eval:astro-v2
        {--days=30 : Lookback days}
        {--outcome-window=7 : Outcome window in days after first message}
        {--out=docs/devlogs/ASTRO_EVAL_V2.md : Markdown output path relative to backend root}';

    protected $description = 'Generate offline evaluation report for Astro 2.0 module outputs.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $outcomeWindow = max(1, (int) $this->option('outcome-window'));
        try {
            $since = now()->subDays($days);
            $rows = DatingMatch::query()
                ->where('created_at', '>=', $since)
                ->get([
                    'id',
                    'created_at',
                    'user_a',
                    'user_b',
                    'like_a',
                    'like_b',
                    'score_final',
                    'score_fair',
                    'match_reasons',
                ]);
        } catch (\Throwable $e) {
            $this->error('Eval query failed: '.$e->getMessage());
            $this->line('Hint: ensure DB driver and connection are available before running this command.');
            return self::FAILURE;
        }

        $total = $rows->count();
        if ($total === 0) {
            $this->warn("No matches found in last {$days} days.");
        }

        $confidenceSum = 0.0;
        $displaySum = 0.0;
        $rankSum = 0.0;
        $moduleStats = [];
        $outcomes = [
            'mutual_like' => 0,
            'first_message' => 0,
            'reply_24h' => 0,
            'sustained_7d' => 0,
            'explanation_view' => 0,
        ];
        $bucket = [
            'low' => ['count' => 0, 'reply_24h' => 0, 'sustained_7d' => 0],
            'mid' => ['count' => 0, 'reply_24h' => 0, 'sustained_7d' => 0],
            'high' => ['count' => 0, 'reply_24h' => 0, 'sustained_7d' => 0],
        ];

        foreach ($rows as $row) {
            $reasons = is_array($row->match_reasons) ? $row->match_reasons : [];
            $confidenceSum += (float) ($reasons['confidence'] ?? 0.0);
            $display = (int) ($reasons['display_score'] ?? ($row->score_final ?? 0));
            $rank = (int) ($reasons['rank_score'] ?? ($row->score_fair ?? 0));
            $displaySum += $display;
            $rankSum += $rank;
            $bucketKey = $rank >= 80 ? 'high' : ($rank >= 60 ? 'mid' : 'low');
            $bucket[$bucketKey]['count']++;

            $pair = $this->pairOrder((int) $row->user_a, (int) $row->user_b);
            $roomId = $this->roomId($pair['a'], $pair['b']);
            $createdAt = $row->created_at ?? now();
            $windowEnd = $createdAt->copy()->addDays($outcomeWindow);

            $mutual = (bool) $row->like_a && (bool) $row->like_b;
            if ($mutual) {
                $outcomes['mutual_like']++;
            }

            $firstMsg = ChatMessage::query()
                ->where('room_id', $roomId)
                ->where('created_at', '>=', $createdAt)
                ->where('created_at', '<=', $windowEnd)
                ->orderBy('id')
                ->first(['id', 'sender_id', 'created_at']);
            $hasFirstMessage = $firstMsg !== null;
            if ($hasFirstMessage) {
                $outcomes['first_message']++;
            }

            $reply24h = false;
            $sustained = false;
            if ($firstMsg) {
                $reply = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>', $firstMsg->created_at)
                    ->where('created_at', '<=', $firstMsg->created_at->copy()->addHours(24))
                    ->where('sender_id', '!=', (int) $firstMsg->sender_id)
                    ->first(['id']);
                $reply24h = $reply !== null;

                $msgs = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>=', $firstMsg->created_at)
                    ->where('created_at', '<=', $firstMsg->created_at->copy()->addDays(7))
                    ->get(['sender_id', 'created_at']);
                $senderCount = $msgs->pluck('sender_id')->unique()->count();
                $msgCount = $msgs->count();
                $activeDays = $msgs
                    ->map(fn ($x) => optional($x->created_at)->format('Y-m-d'))
                    ->filter()
                    ->unique()
                    ->count();
                $sustained = $senderCount >= 2 && ($msgCount >= 6 || $activeDays >= 3);
            }
            if ($reply24h) {
                $outcomes['reply_24h']++;
                $bucket[$bucketKey]['reply_24h']++;
            }
            if ($sustained) {
                $outcomes['sustained_7d']++;
                $bucket[$bucketKey]['sustained_7d']++;
            }

            $viewed = AppEvent::query()
                ->where('event_name', 'match_explanation_view')
                ->where('match_id', (int) $row->id)
                ->where('created_at', '>=', $createdAt)
                ->exists();
            if ($viewed) {
                $outcomes['explanation_view']++;
            }

            $modules = (array) ($reasons['modules'] ?? []);
            foreach ($modules as $module) {
                if (!is_array($module)) {
                    continue;
                }
                $key = strtolower(trim((string) ($module['key'] ?? 'unknown')));
                if ($key === '') {
                    $key = 'unknown';
                }
                if (!isset($moduleStats[$key])) {
                    $moduleStats[$key] = [
                        'count' => 0,
                        'score_sum' => 0.0,
                        'confidence_sum' => 0.0,
                        'degraded_count' => 0,
                    ];
                }
                $moduleStats[$key]['count']++;
                $moduleStats[$key]['score_sum'] += (float) ($module['score'] ?? 0.0);
                $moduleStats[$key]['confidence_sum'] += (float) ($module['confidence'] ?? 0.0);
                if ((bool) ($module['degraded'] ?? false)) {
                    $moduleStats[$key]['degraded_count']++;
                }
            }
        }

        ksort($moduleStats);
        $out = trim((string) $this->option('out'));
        $out = $out !== '' ? $out : 'docs/devlogs/ASTRO_EVAL_V2.md';
        $outPath = base_path($out);
        $this->ensureParentDirectory($outPath);

        $md = [];
        $md[] = '# Astro 2.0 Offline Eval';
        $md[] = '';
        $md[] = '- Generated At: '.Carbon::now()->toIso8601String();
        $md[] = '- Window: last '.$days.' day(s)';
        $md[] = '- Samples: '.$total;
        $md[] = '';
        if ($total > 0) {
            $md[] = '## Aggregate';
            $md[] = '';
            $md[] = '- Avg Confidence: '.number_format($confidenceSum / $total, 3);
            $md[] = '- Avg Display Score: '.number_format($displaySum / $total, 2);
            $md[] = '- Avg Rank Score: '.number_format($rankSum / $total, 2);
            $md[] = '';
            $md[] = '## Outcome Funnel';
            $md[] = '';
            $md[] = '- Mutual Like: '.$outcomes['mutual_like'].' ('.$this->pct($outcomes['mutual_like'], $total).'%)';
            $md[] = '- First Message: '.$outcomes['first_message'].' ('.$this->pct($outcomes['first_message'], $total).'%)';
            $md[] = '- Reply in 24h: '.$outcomes['reply_24h'].' ('.$this->pct($outcomes['reply_24h'], $total).'%)';
            $md[] = '- Sustained 7d: '.$outcomes['sustained_7d'].' ('.$this->pct($outcomes['sustained_7d'], $total).'%)';
            $md[] = '- Explanation View: '.$outcomes['explanation_view'].' ('.$this->pct($outcomes['explanation_view'], $total).'%)';
            $md[] = '';
            $md[] = '## Rank Score vs Outcome';
            $md[] = '';
            $md[] = '| Bucket | Samples | Reply24h | Sustained7d |';
            $md[] = '|---|---:|---:|---:|';
            foreach (['low', 'mid', 'high'] as $k) {
                $c = max(1, (int) $bucket[$k]['count']);
                $md[] = sprintf(
                    '| %s | %d | %.2f%% | %.2f%% |',
                    $k,
                    (int) $bucket[$k]['count'],
                    ((int) $bucket[$k]['reply_24h']) * 100 / $c,
                    ((int) $bucket[$k]['sustained_7d']) * 100 / $c
                );
            }
            $md[] = '';
        }
        $md[] = '## Module Breakdown';
        $md[] = '';
        $md[] = '| Module | Count | Avg Score | Avg Confidence | Degraded Ratio |';
        $md[] = '|---|---:|---:|---:|---:|';
        foreach ($moduleStats as $key => $stat) {
            $c = max(1, (int) $stat['count']);
            $avgScore = $stat['score_sum'] / $c;
            $avgConf = $stat['confidence_sum'] / $c;
            $degRatio = ((int) $stat['degraded_count']) / $c;
            $md[] = sprintf(
                '| %s | %d | %.2f | %.3f | %.2f%% |',
                $key,
                $c,
                $avgScore,
                $avgConf,
                $degRatio * 100
            );
        }
        $md[] = '';
        $md[] = '## Notes';
        $md[] = '';
        $md[] = '- `display_score` is user-facing readability score.';
        $md[] = '- `rank_score` is ordering score (fairness-adjusted).';
        $md[] = '- Rank buckets: low < 60, mid 60~79, high >= 80.';
        $md[] = '- Degraded ratio > 20% usually indicates missing input fields or incomplete birth data.';
        $md[] = '';

        file_put_contents($outPath, implode(PHP_EOL, $md).PHP_EOL);

        $this->info("Astro eval report generated: {$outPath}");
        $this->line('samples='.$total);
        $this->line('modules='.count($moduleStats));
        $this->line('reply24h='.$outcomes['reply_24h']);
        $this->line('sustained7d='.$outcomes['sustained_7d']);

        return self::SUCCESS;
    }

    private function pct(int $num, int $den): string
    {
        if ($den <= 0) {
            return '0.00';
        }
        return number_format(($num * 100.0) / $den, 2);
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

    private function ensureParentDirectory(string $path): void
    {
        $dir = dirname($path);
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
    }
}
