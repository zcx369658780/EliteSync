<?php

use Illuminate\Foundation\Inspiring;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;

Artisan::command('inspire', function () {
    $this->comment(Inspiring::quote());
})->purpose('Display an inspiring quote');

Artisan::command('metrics:daily {--days=7}', function () {
    $days = max(1, (int) $this->option('days'));
    $since = now()->subDays($days);

    $matchExposed = DB::table('app_events')
        ->where('event_name', 'match_exposed')
        ->where('created_at', '>=', $since)
        ->count();
    $matchConfirm = DB::table('app_events')
        ->where('event_name', 'match_confirm')
        ->where('created_at', '>=', $since)
        ->count();
    $replyCount = DB::table('app_events')
        ->where('event_name', 'message_sent')
        ->where('created_at', '>=', $since)
        ->count();

    $top10Share = 0.0;
    $exposures = DB::table('app_events')
        ->selectRaw('target_user_id, COUNT(*) c')
        ->where('event_name', 'match_exposed')
        ->where('created_at', '>=', $since)
        ->whereNotNull('target_user_id')
        ->groupBy('target_user_id')
        ->orderByDesc('c')
        ->pluck('c')
        ->values();
    $n = $exposures->count();
    if ($n > 0) {
        $topN = max(1, (int) ceil($n * 0.10));
        $topSum = $exposures->take($topN)->sum();
        $total = $exposures->sum();
        if ($total > 0) {
            $top10Share = $topSum / $total;
        }
    }

    $this->info("Window: last {$days} day(s)");
    $this->line("match_exposed: {$matchExposed}");
    $this->line("match_confirm: {$matchConfirm}");
    $this->line("message_sent: {$replyCount}");
    $this->line('top10_exposure_share: '.number_format($top10Share * 100, 2).'%');

    return 0;
})->purpose('Show daily core matching metrics (exposure/confirm/reply/top10 share)');
