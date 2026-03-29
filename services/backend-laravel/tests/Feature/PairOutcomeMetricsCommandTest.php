<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class PairOutcomeMetricsCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_pair_outcome_metrics_command_generates_report_with_expected_keys(): void
    {
        $this->seed();

        $a = User::create([
            'phone' => '13800009991',
            'name' => 'metrics-a',
            'password' => 'secret123',
        ]);
        $b = User::create([
            'phone' => '13800009992',
            'name' => 'metrics-b',
            'password' => 'secret123',
        ]);

        $match = DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => $a->id,
            'user_b' => $b->id,
            'drop_released' => true,
            'like_a' => true,
            'like_b' => true,
            'match_reasons' => ['summary' => 'test'],
        ]);

        ChatMessage::create([
            'room_id' => min($a->id, $b->id).'_'.max($a->id, $b->id),
            'sender_id' => $a->id,
            'receiver_id' => $b->id,
            'content' => 'hello',
        ]);
        ChatMessage::create([
            'room_id' => min($a->id, $b->id).'_'.max($a->id, $b->id),
            'sender_id' => $b->id,
            'receiver_id' => $a->id,
            'content' => 'reply',
        ]);

        AppEvent::create([
            'event_name' => 'match_explanation_view',
            'actor_user_id' => $a->id,
            'target_user_id' => $b->id,
            'match_id' => $match->id,
            'payload' => ['from' => 'test'],
        ]);

        $jsonPath = 'docs/devlogs/PAIR_OUTCOME_METRICS_TEST.json';
        $mdPath = 'docs/devlogs/PAIR_OUTCOME_METRICS_TEST.md';
        @unlink(base_path($jsonPath));
        @unlink(base_path($mdPath));

        $code = Artisan::call('app:dev:pair-outcome-metrics', [
            '--days' => 60,
            '--json' => $jsonPath,
            '--out' => $mdPath,
        ]);

        $this->assertSame(0, $code);
        $this->assertFileExists(base_path($jsonPath));
        $report = json_decode((string) file_get_contents(base_path($jsonPath)), true);
        $this->assertIsArray($report);
        $summary = (array) ($report['summary'] ?? []);
        $this->assertArrayHasKey('total_pairs', $summary);
        $this->assertArrayHasKey('mutual_like_pairs', $summary);
        $this->assertArrayHasKey('first_message_pairs', $summary);
        $this->assertArrayHasKey('reply_24h_pairs', $summary);
        $this->assertArrayHasKey('sustained_7d_pairs', $summary);
        $this->assertArrayHasKey('explanation_view_pairs', $summary);
    }
}

