<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class FrontendTelemetryApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_frontend_telemetry_logs_distinct_events(): void
    {
        $user = User::create([
            'phone' => '13800003100',
            'name' => 'TelemetryUser',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $target = User::create([
            'phone' => '13800003101',
            'name' => 'TelemetryTarget',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $match = DatingMatch::create([
            'week_tag' => '20260409',
            'user_a' => $user->id,
            'user_b' => $target->id,
            'drop_released' => true,
            'like_a' => true,
            'like_b' => true,
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/telemetry/events', [
            'event_name' => 'match_first_chat_entry',
            'target_user_id' => $target->id,
            'match_id' => $match->id,
            'payload' => [
                'entry_point' => 'match_result',
            ],
        ], [
            'X-App-Version' => '0.03.01',
            'X-Source-Page' => 'match_result',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_first_chat_entry',
            'actor_user_id' => $user->id,
            'target_user_id' => $target->id,
            'match_id' => $match->id,
        ]);

        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_first_chat_entry',
            'actor_user_id' => $user->id,
        ]);

        $event = AppEvent::query()->where('event_name', 'match_first_chat_entry')->firstOrFail();
        $this->assertSame('match_result', $event->payload['source_page'] ?? null);
        $this->assertSame('0.03.01', $event->payload['app_version'] ?? null);
        $this->assertSame('match_first_chat_entry', $event->payload['client_event'] ?? null);
        $this->assertSame('match_result', $event->payload['client_payload']['entry_point'] ?? null);
    }

    public function test_frontend_telemetry_logs_rtc_events(): void
    {
        $user = User::create([
            'phone' => '13800003110',
            'name' => 'RtcUser',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/telemetry/events', [
            'event_name' => 'rtc_call_entry_opened',
            'source_page' => 'chat_room',
            'payload' => [
                'surface' => 'rtc_call_entry',
                'call_id' => 66,
            ],
        ], [
            'X-App-Version' => '0.04.06',
            'X-Source-Page' => 'chat_room',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertDatabaseHas('app_events', [
            'event_name' => 'rtc_call_entry_opened',
            'actor_user_id' => $user->id,
        ]);

        $event = AppEvent::query()->where('event_name', 'rtc_call_entry_opened')->firstOrFail();
        $this->assertSame('chat_room', $event->payload['source_page'] ?? null);
        $this->assertSame('rtc_call_entry_opened', $event->payload['client_event'] ?? null);
        $this->assertSame(66, $event->payload['client_payload']['call_id'] ?? null);
    }
}

