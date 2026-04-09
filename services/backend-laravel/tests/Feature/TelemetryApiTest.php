<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class TelemetryApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_frontend_telemetry_routes_store_distinct_events(): void
    {
        $actor = User::create([
            'phone' => '13800001001',
            'name' => 'TelemetryActor',
            'password' => 'secret123',
        ]);
        $target = User::create([
            'phone' => '13800001002',
            'name' => 'TelemetryTarget',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($actor);

        $this->postJson('/api/v1/telemetry/match-explanation-preview-opened', [
            'event_name' => 'match_explanation_preview_opened',
            'target_user_id' => $target->id,
            'source_page' => 'match_result',
            'payload' => ['surface' => 'match_result'],
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/telemetry/first-chat-entry', [
            'event_name' => 'match_first_chat_entry',
            'target_user_id' => $target->id,
            'source_page' => 'match_result',
            'payload' => ['surface' => 'match_result'],
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/telemetry/match-feedback-submitted', [
            'event_name' => 'match_feedback_submitted',
            'target_user_id' => $target->id,
            'source_page' => 'match_feedback',
            'payload' => ['surface' => 'match_feedback'],
        ])->assertOk()->assertJsonPath('ok', true);

        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_explanation_preview_opened',
            'actor_user_id' => $actor->id,
            'target_user_id' => $target->id,
        ]);
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_first_chat_entry',
            'actor_user_id' => $actor->id,
            'target_user_id' => $target->id,
        ]);
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_feedback_submitted',
            'actor_user_id' => $actor->id,
            'target_user_id' => $target->id,
        ]);

        $this->assertSame(3, AppEvent::query()->count());
    }
}
