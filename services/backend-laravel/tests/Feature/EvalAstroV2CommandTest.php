<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class EvalAstroV2CommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_eval_astro_v2_report_contains_outcome_sections(): void
    {
        $this->seed();

        $a = User::create([
            'phone' => '13800008991',
            'name' => 'eval-a',
            'password' => 'secret123',
        ]);
        $b = User::create([
            'phone' => '13800008992',
            'name' => 'eval-b',
            'password' => 'secret123',
        ]);

        $match = DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => $a->id,
            'user_b' => $b->id,
            'drop_released' => true,
            'like_a' => true,
            'like_b' => true,
            'score_final' => 78,
            'score_fair' => 82,
            'match_reasons' => [
                'confidence' => 0.76,
                'display_score' => 78,
                'rank_score' => 82,
                'modules' => [
                    ['key' => 'bazi', 'score' => 80, 'confidence' => 0.8, 'degraded' => false],
                ],
            ],
        ]);

        $roomId = min($a->id, $b->id).'_'.max($a->id, $b->id);
        ChatMessage::create([
            'room_id' => $roomId,
            'sender_id' => $a->id,
            'receiver_id' => $b->id,
            'content' => 'hello',
        ]);
        ChatMessage::create([
            'room_id' => $roomId,
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

        $path = 'docs/devlogs/ASTRO_EVAL_V2_TEST.md';
        @unlink(base_path($path));

        $code = Artisan::call('app:eval:astro-v2', [
            '--days' => 60,
            '--outcome-window' => 7,
            '--out' => $path,
        ]);
        $this->assertSame(0, $code);
        $this->assertFileExists(base_path($path));

        $content = (string) file_get_contents(base_path($path));
        $this->assertStringContainsString('## Outcome Funnel', $content);
        $this->assertStringContainsString('## Rank Score vs Outcome', $content);
    }
}

