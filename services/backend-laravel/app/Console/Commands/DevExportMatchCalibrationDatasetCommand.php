<?php

namespace App\Console\Commands;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use Illuminate\Console\Command;

class DevExportMatchCalibrationDatasetCommand extends Command
{
    protected $signature = 'app:dev:export-match-calibration
        {--days=90 : Lookback window in days}
        {--week-tag= : Optional week_tag filter}
        {--limit=0 : Optional latest match limit (0 means no limit)}
        {--out-json=docs/devlogs/MATCH_CALIBRATION_DATASET.json : JSON output path}
        {--out-csv=docs/devlogs/MATCH_CALIBRATION_DATASET.csv : CSV output path}
        {--include-calibration-injected : Include calibration-injected chat/events in outcomes}
        {--outcome-window=7 : Outcome window in days after first message}';

    protected $description = 'Export flattened match dataset for offline score-weight calibration.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        $weekTag = trim((string) $this->option('week-tag'));
        $limit = max(0, (int) $this->option('limit'));
        $outJson = trim((string) $this->option('out-json'));
        $outCsv = trim((string) $this->option('out-csv'));
        $outcomeWindow = max(1, (int) $this->option('outcome-window'));
        $includeInjected = (bool) $this->option('include-calibration-injected')
            || (bool) config('matching.calibration_injector.include_in_metrics_default', false);
        $markerPrefix = trim((string) config('matching.calibration_injector.message_marker_prefix', '[[calibration_injector]]'));
        if ($markerPrefix === '') {
            $markerPrefix = '[[calibration_injector]]';
        }
        $markerLike = $markerPrefix.'%';
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

        $matches = $q->get([
            'id',
            'week_tag',
            'created_at',
            'user_a',
            'user_b',
            'like_a',
            'like_b',
            'score_final',
            'score_fair',
            'score_personality_total',
            'score_mbti_total',
            'score_astro_total',
            'score_bazi',
            'score_zodiac',
            'score_constellation',
            'score_natal_chart',
            'match_reasons',
        ]);

        if ($matches->isEmpty()) {
            $this->warn('No released matches found for calibration export.');
            return self::SUCCESS;
        }

        $rows = [];
        foreach ($matches as $m) {
            $pair = $this->pairOrder((int) $m->user_a, (int) $m->user_b);
            $roomId = $this->roomId($pair['a'], $pair['b']);
            $createdAt = $m->created_at ?? now();
            $windowEnd = $createdAt->copy()->addDays($outcomeWindow);
            $reasons = is_array($m->match_reasons) ? $m->match_reasons : [];
            $modules = $this->indexModules((array) ($reasons['modules'] ?? []));

            $firstMsgQ = ChatMessage::query()
                ->where('room_id', $roomId)
                ->where('created_at', '>=', $createdAt)
                ->where('created_at', '<=', $windowEnd);
            if (!$includeInjected) {
                $firstMsgQ->where(function ($qq) use ($markerLike) {
                    $qq->whereNull('content')->orWhere('content', 'not like', $markerLike);
                });
            }
            $firstMsg = $firstMsgQ->orderBy('id')->first(['id', 'sender_id', 'created_at']);
            $firstMessage = $firstMsg !== null;

            $reply24h = false;
            $sustained7d = false;
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
                $reply = $replyQ->first(['id']);
                $reply24h = $reply !== null;

                $msgsQ = ChatMessage::query()
                    ->where('room_id', $roomId)
                    ->where('created_at', '>=', $firstMsg->created_at)
                    ->where('created_at', '<=', $firstMsg->created_at->copy()->addDays(7));
                if (!$includeInjected) {
                    $msgsQ->where(function ($qq) use ($markerLike) {
                        $qq->whereNull('content')->orWhere('content', 'not like', $markerLike);
                    });
                }
                $msgs = $msgsQ->get(['sender_id', 'created_at']);
                $senderCount = $msgs->pluck('sender_id')->unique()->count();
                $msgCount = $msgs->count();
                $activeDays = $msgs
                    ->map(fn ($x) => optional($x->created_at)->format('Y-m-d'))
                    ->filter()
                    ->unique()
                    ->count();
                $sustained7d = $senderCount >= 2 && ($msgCount >= 6 || $activeDays >= 3);
            }

            $eventNames = $includeInjected
                ? ['match_explanation_view', 'match_explanation_view_calibration']
                : ['match_explanation_view'];
            $explanationView = AppEvent::query()
                ->whereIn('event_name', $eventNames)
                ->where('match_id', (int) $m->id)
                ->where('created_at', '>=', $createdAt)
                ->exists();

            $row = [
                'match_id' => (int) $m->id,
                'week_tag' => (string) ($m->week_tag ?? ''),
                'created_at' => optional($createdAt)->toIso8601String(),
                'user_a' => $pair['a'],
                'user_b' => $pair['b'],
                'display_score' => (int) ($reasons['display_score'] ?? $m->score_final ?? 0),
                'rank_score' => (int) ($reasons['rank_score'] ?? $m->score_fair ?? 0),
                'overall_confidence' => (float) ($reasons['confidence'] ?? 0.5),
                'score_personality_total' => (int) ($m->score_personality_total ?? 0),
                'score_mbti_total' => (int) ($m->score_mbti_total ?? 0),
                'score_astro_total' => (int) ($m->score_astro_total ?? 0),
                'score_bazi' => (int) ($m->score_bazi ?? 0),
                'score_zodiac' => (int) ($m->score_zodiac ?? 0),
                'score_constellation' => (int) ($m->score_constellation ?? 0),
                'score_natal_chart' => (int) ($m->score_natal_chart ?? 0),
                'mutual_like' => ((bool) $m->like_a && (bool) $m->like_b) ? 1 : 0,
                'first_message' => $firstMessage ? 1 : 0,
                'reply_24h' => $reply24h ? 1 : 0,
                'sustained_7d' => $sustained7d ? 1 : 0,
                'explanation_view' => $explanationView ? 1 : 0,
            ];

            foreach (['personality', 'mbti', 'bazi', 'zodiac', 'constellation', 'natal_chart', 'pair_chart'] as $k) {
                $mod = (array) ($modules[$k] ?? []);
                $row["m_{$k}_score"] = (int) ($mod['score'] ?? 0);
                $row["m_{$k}_confidence"] = (float) ($mod['confidence'] ?? 0.0);
                $row["m_{$k}_degraded"] = ((bool) ($mod['degraded'] ?? false)) ? 1 : 0;
                $row["m_{$k}_weight"] = (float) ($mod['weight'] ?? 0.0);
                $row["m_{$k}_verdict"] = (string) ($mod['verdict'] ?? '');
            }

            // Useful for ranking training / calibration.
            $row['label_positive_reply24h'] = $row['reply_24h'];
            $row['label_positive_sustained7d'] = $row['sustained_7d'];

            $rows[] = $row;
        }

        $report = [
            'generated_at' => now()->toIso8601String(),
            'window' => [
                'days' => $days,
                'week_tag' => $weekTag,
                'since' => $since->toIso8601String(),
                'limit' => $limit,
                'outcome_window_days' => $outcomeWindow,
                'include_calibration_injected' => $includeInjected,
            ],
            'count' => count($rows),
            'columns' => !empty($rows) ? array_keys($rows[0]) : [],
            'rows' => $rows,
        ];

        $this->writeJson(base_path($outJson), $report);
        $this->writeCsv(base_path($outCsv), $rows);

        $this->info('Calibration dataset exported.');
        $this->line('rows='.count($rows));
        $this->line('json='.base_path($outJson));
        $this->line('csv='.base_path($outCsv));

        return self::SUCCESS;
    }

    /**
     * @param array<int,array<string,mixed>> $modules
     * @return array<string,array<string,mixed>>
     */
    private function indexModules(array $modules): array
    {
        $out = [];
        foreach ($modules as $mod) {
            if (!is_array($mod)) {
                continue;
            }
            $key = strtolower(trim((string) ($mod['key'] ?? '')));
            if ($key === '') {
                continue;
            }
            $out[$key] = $mod;
        }
        return $out;
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
     * @param string $path
     * @param array<string,mixed> $data
     */
    private function writeJson(string $path, array $data): void
    {
        $this->ensureParentDirectory($path);
        file_put_contents($path, json_encode($data, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE));
    }

    /**
     * @param string $path
     * @param array<int,array<string,mixed>> $rows
     */
    private function writeCsv(string $path, array $rows): void
    {
        $this->ensureParentDirectory($path);
        $fp = fopen($path, 'w');
        if ($fp === false) {
            throw new \RuntimeException('Cannot open CSV output: '.$path);
        }
        if (empty($rows)) {
            fclose($fp);
            return;
        }
        $headers = array_keys($rows[0]);
        fputcsv($fp, $headers);
        foreach ($rows as $row) {
            $line = [];
            foreach ($headers as $h) {
                $line[] = $row[$h] ?? null;
            }
            fputcsv($fp, $line);
        }
        fclose($fp);
    }

    private function ensureParentDirectory(string $path): void
    {
        $dir = dirname($path);
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
    }
}
