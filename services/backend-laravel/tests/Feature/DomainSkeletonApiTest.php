<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class DomainSkeletonApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_conversation_and_media_skeleton_routes_are_available(): void
    {
        $user = User::create([
            'phone' => '13800000021',
            'name' => 'Skeleton',
            'password' => 'secret123',
        ]);
        $peer = User::create([
            'phone' => '13800000022',
            'name' => 'Peer',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('items', [])
            ->assertJsonPath('total', 0)
            ->assertJsonPath('note', '4.0A conversation domain skeleton only');

        $this->postJson('/api/v1/conversations', [
            'peer_user_id' => $peer->id,
            'title' => 'demo',
        ])->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('conversation.room_key', '1_2');

        $this->getJson("/api/v1/conversations/{$peer->id}")
            ->assertOk()
            ->assertJsonPath('domain', 'conversation')
            ->assertJsonPath('conversation.room_key', '1_2');

        $this->getJson('/api/v1/media')
            ->assertOk()
            ->assertJsonPath('domain', 'media')
            ->assertJsonPath('states.0', 'pending');

        $mediaResponse = $this->postJson('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'sample.png',
            'mime_type' => 'image/png',
        ])->assertOk()
            ->assertJsonPath('domain', 'media')
            ->assertJsonPath('asset.media_type', 'image');

        $assetId = (int) $mediaResponse->json('asset.id');

        $this->getJson("/api/v1/media/{$assetId}")
            ->assertOk()
            ->assertJsonPath('domain', 'media');

        $this->getJson('/api/v1/relationships')
            ->assertOk()
            ->assertJsonPath('total', 0);

        $this->postJson('/api/v1/relationships', [
            'subject_user_id' => $peer->id,
            'event_type' => 'follow',
        ])->assertOk()
            ->assertJsonPath('event.subject_user_id', $peer->id);

        $this->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonPath('total', 0)
            ->assertJsonPath('unread_total', 0);
    }
}
