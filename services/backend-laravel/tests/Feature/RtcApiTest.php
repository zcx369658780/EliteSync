<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\DatingMatch;
use App\Models\RtcSession;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Carbon;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class RtcApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    private function makeMatchedUsers(string $callerPhone, string $calleePhone): array
    {
        $caller = User::create([
            'phone' => $callerPhone,
            'name' => 'Caller',
            'password' => 'secret123',
        ]);
        $callee = User::create([
            'phone' => $calleePhone,
            'name' => 'Callee',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $caller->id,
            'user_b' => $callee->id,
            'drop_released' => true,
        ]);

        return [$caller, $callee];
    }

    public function test_create_accept_connect_and_end_voice_call_flow(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004101', '13800004102');

        Sanctum::actingAs($caller);
        $create = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->assertJsonPath('session.status', 'calling')
            ->json('session');

        $callId = (int) $create['id'];
        $this->assertDatabaseHas('rtc_sessions', [
            'id' => $callId,
            'initiator_user_id' => $caller->id,
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
            'status' => 'calling',
        ]);

        $invite = AppNotificationItem::query()
            ->where('user_id', $callee->id)
            ->where('kind', 'rtc_call_invite')
            ->firstOrFail();
        $this->assertSame('rtc_call', $invite->payload['route_name'] ?? null);
        $this->assertSame($callId, (int) ($invite->payload['route_args']['call_id'] ?? 0));
        $this->assertLessThanOrEqual(
            12,
            abs(Carbon::parse((string) $create['expires_at'])->diffInSeconds(now()))
        );

        Sanctum::actingAs($callee);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/accept')
            ->assertOk()
            ->assertJsonPath('session.status', 'connecting');

        $this->assertDatabaseHas('rtc_session_events', [
            'rtc_session_id' => $callId,
            'event_name' => 'accepted',
        ]);

        Sanctum::actingAs($callee);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/connect')
            ->assertOk()
            ->assertJsonPath('session.status', 'in_call');

        Sanctum::actingAs($caller);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/end')
            ->assertOk()
            ->assertJsonPath('session.status', 'ended');

        $this->assertDatabaseHas('rtc_session_events', [
            'rtc_session_id' => $callId,
            'event_name' => 'ended',
        ]);
    }

    public function test_heartbeat_closes_call_when_peer_is_stale(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004103', '13800004104');

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->json('session');
        $callId = (int) $session['id'];

        Sanctum::actingAs($callee);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/accept')->assertOk();

        Sanctum::actingAs($caller);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/connect')->assertOk();

        RtcSession::query()
            ->whereKey($callId)
            ->update([
                'status' => 'in_call',
                'started_at' => now()->subSeconds(32),
                'initiator_last_seen_at' => now(),
                'peer_last_seen_at' => now()->subSeconds(31),
                'expires_at' => now()->addMinutes(20),
            ]);

        Sanctum::actingAs($caller);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/heartbeat')
            ->assertOk()
            ->assertJsonPath('session.status', 'ended')
            ->assertJsonPath('session.failure_code', 'peer_disconnected');

        $this->assertDatabaseHas('rtc_session_events', [
            'rtc_session_id' => $callId,
            'event_name' => 'heartbeat',
        ]);
        $this->assertDatabaseHas('rtc_session_events', [
            'rtc_session_id' => $callId,
            'event_name' => 'disconnected',
        ]);
    }

    public function test_livekit_join_info_returns_signed_token_for_participants(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004103', '13800004104');
        config()->set('livekit.enabled', true);
        config()->set('livekit.url', 'wss://rtc.example.test');
        config()->set('livekit.api_key', 'test_key');
        config()->set('livekit.api_secret', 'test_secret');
        config()->set('livekit.ttl_seconds', 600);

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])->assertOk()->json('session');

        $callId = (int) $session['id'];

        $response = $this->getJson('/api/v1/rtc/calls/' . $callId . '/livekit')
            ->assertOk()
            ->json('livekit');

        $this->assertSame('wss://rtc.example.test', $response['url']);
        $this->assertSame('voice', $response['mode']);
        $this->assertSame('rtc-user-' . $caller->id, $response['identity']);
        $this->assertSame($session['room_key'], $response['room_name']);
        $this->assertNotEmpty($response['token']);

        $token = (string) $response['token'];
        [$headerPart, $payloadPart, $signaturePart] = explode('.', $token);
        $this->assertNotEmpty($headerPart);
        $this->assertNotEmpty($payloadPart);
        $this->assertNotEmpty($signaturePart);

        $payload = json_decode($this->base64UrlDecode($payloadPart), true, 512, JSON_THROW_ON_ERROR);
        $this->assertSame('test_key', $payload['iss']);
        $this->assertSame('rtc-user-' . $caller->id, $payload['sub']);
        $this->assertTrue($payload['video']['roomJoin']);
        $this->assertSame($session['room_key'], $payload['video']['room']);
    }

    public function test_livekit_join_info_rejects_non_participants(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004105', '13800004106');
        $intruder = User::create([
            'phone' => '13800004107',
            'name' => 'Intruder',
            'password' => 'secret123',
        ]);
        config()->set('livekit.enabled', true);
        config()->set('livekit.url', 'wss://rtc.example.test');
        config()->set('livekit.api_key', 'test_key');
        config()->set('livekit.api_secret', 'test_secret');

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])->assertOk()->json('session');

        Sanctum::actingAs($intruder);
        $this->getJson('/api/v1/rtc/calls/' . (int) $session['id'] . '/livekit')
            ->assertStatus(404);
    }

    public function test_reject_call_updates_status_and_notifies_caller(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004111', '13800004112');

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->json('session');
        $callId = (int) $session['id'];

        Sanctum::actingAs($callee);
        $this->postJson('/api/v1/rtc/calls/' . $callId . '/reject')
            ->assertOk()
            ->assertJsonPath('session.status', 'rejected');

        $this->assertDatabaseHas('notifications', [
            'user_id' => $caller->id,
            'kind' => 'rtc_call_rejected',
            'title' => '通话已拒绝',
        ]);
    }

    public function test_busy_call_returns_busy_status_when_pair_has_active_call(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004121', '13800004122');

        Sanctum::actingAs($caller);
        $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])->assertOk();

        Sanctum::actingAs($callee);
        $busy = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $caller->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->assertJsonPath('session.status', 'busy')
            ->json('session');

        $this->assertSame('busy', $busy['status']);
        $this->assertDatabaseHas('rtc_sessions', [
            'id' => (int) $busy['id'],
            'status' => 'busy',
            'failure_code' => 'peer_busy',
        ]);
    }

    public function test_create_call_ignores_expired_active_call_when_pair_is_no_longer_busy(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004131', '13800004132');

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])->assertOk()->json('session');

        $callId = (int) $session['id'];
        RtcSession::query()
            ->whereKey($callId)
            ->update([
                'status' => 'calling',
                'expires_at' => now()->subMinute(),
            ]);

        Sanctum::actingAs($callee);
        $next = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $caller->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->assertJsonPath('session.status', 'calling')
            ->json('session');

        $this->assertSame('calling', $next['status']);
        $this->assertNotSame('busy', $next['status']);
    }

    public function test_create_call_ignores_expired_connecting_call_when_pair_is_no_longer_busy(): void
    {
        [$caller, $callee] = $this->makeMatchedUsers('13800004141', '13800004142');

        Sanctum::actingAs($caller);
        $session = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])->assertOk()->json('session');

        $callId = (int) $session['id'];
        RtcSession::query()
            ->whereKey($callId)
            ->update([
                'status' => 'connecting',
                'accepted_at' => now()->subMinutes(3),
                'expires_at' => now()->subMinute(),
            ]);

        Sanctum::actingAs($caller);
        $next = $this->postJson('/api/v1/rtc/calls', [
            'peer_user_id' => $callee->id,
            'mode' => 'voice',
        ])
            ->assertOk()
            ->assertJsonPath('session.status', 'calling')
            ->json('session');

        $this->assertSame('calling', $next['status']);
        $this->assertNotSame('busy', $next['status']);
    }

    private function base64UrlDecode(string $value): string
    {
        $remainder = strlen($value) % 4;
        if ($remainder > 0) {
            $value .= str_repeat('=', 4 - $remainder);
        }

        return base64_decode(strtr($value, '-_', '+/'), true) ?: '';
    }
}
