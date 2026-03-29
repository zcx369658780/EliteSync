<?php

namespace App\Console\Commands;

use App\Models\DatingMatch;
use Illuminate\Console\Command;
use Illuminate\Support\Carbon;

class EvalAstroV2Command extends Command
{
    protected $signature = 'app:eval:astro-v2
        {--days=30 : Lookback days}
        {--out=docs/devlogs/ASTRO_EVAL_V2.md : Markdown output path relative to backend root}';

    protected $description = 'Generate offline evaluation report for Astro 2.0 module outputs.';

    public function handle(): int
    {
        $days = max(1, (int) $this->option('days'));
        try {
            $since = now()->subDays($days);
            $rows = DatingMatch::query()
                ->where('created_at', '>=', $since)
                ->get(['id', 'created_at', 'score_final', 'score_fair', 'match_reasons']);
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

        foreach ($rows as $row) {
            $reasons = is_array($row->match_reasons) ? $row->match_reasons : [];
            $confidenceSum += (float) ($reasons['confidence'] ?? 0.0);
            $display = (int) ($reasons['display_score'] ?? ($row->score_final ?? 0));
            $rank = (int) ($reasons['rank_score'] ?? ($row->score_fair ?? 0));
            $displaySum += $display;
            $rankSum += $rank;

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
        $md[] = '- Degraded ratio > 20% usually indicates missing input fields or incomplete birth data.';
        $md[] = '';

        file_put_contents($outPath, implode(PHP_EOL, $md).PHP_EOL);

        $this->info("Astro eval report generated: {$outPath}");
        $this->line('samples='.$total);
        $this->line('modules='.count($moduleStats));

        return self::SUCCESS;
    }

    private function ensureParentDirectory(string $path): void
    {
        $dir = dirname($path);
        if (!is_dir($dir)) {
            mkdir($dir, 0777, true);
        }
    }
}
