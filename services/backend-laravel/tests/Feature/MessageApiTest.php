<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\MediaAsset;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MessageApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function test_send_list_and_mark_read_message_flow(): void
    {
        $userA = User::create([
            'phone' => '13800000011',
            'name' => 'A',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000012',
            'name' => 'B',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'hello',
        ])->assertOk()->assertJsonPath('ok', true)->json();
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'message_sent',
            'actor_user_id' => $userA->id,
            'target_user_id' => $userB->id,
        ]);

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.content', 'hello');

        $this->postJson('/api/v1/messages/read/'.$messageId)
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('items.0.is_read', true);
    }

    public function test_image_attachment_can_be_bound_to_message_and_listed(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);

        $userA = User::create([
            'phone' => '13800000015',
            'name' => 'A3',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000016',
            'name' => 'B3',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/image/test.jpg',
            'original_name' => 'test.jpg',
            'mime_type' => 'image/jpeg',
            'size_bytes' => 1024,
            'width' => 640,
            'height' => 480,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/image/test.jpg',
            'metadata' => ['kind' => 'image'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        $expectedImageUrl = 'http://localhost:8080/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => '',
            'attachment_ids' => [$asset->id],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('message.has_attachments', true)
            ->assertJsonPath('message.attachments.0.media_asset.public_url', $expectedImageUrl)
            ->json();

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '图片消息');

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.message_type', 'image')
            ->assertJsonPath('items.0.attachments.0.media_asset.id', $asset->id);
    }

    public function test_video_attachment_can_be_bound_to_message_and_listed(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);

        $userA = User::create([
            'phone' => '13800000017',
            'name' => 'A4',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000018',
            'name' => 'B4',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'video',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/video/test.mp4',
            'original_name' => 'test.mp4',
            'mime_type' => 'video/mp4',
            'size_bytes' => 2048,
            'width' => 1280,
            'height' => 720,
            'duration_ms' => 65000,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/video/test.mp4',
            'metadata' => ['kind' => 'video'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        $expectedVideoUrl = 'http://localhost:8080/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => '',
            'attachment_ids' => [$asset->id],
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('message.has_attachments', true)
            ->assertJsonPath('message.attachments.0.media_asset.public_url', $expectedVideoUrl)
            ->json();

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '视频消息');

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.message_type', 'video')
            ->assertJsonPath('items.0.attachments.0.media_asset.id', $asset->id)
            ->assertJsonPath('items.0.attachments.0.media_asset.duration_ms', 65000);
    }

    public function test_video_attachment_preview_takes_priority_over_content(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);

        $userA = User::create([
            'phone' => '13800000019',
            'name' => 'A5',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000020',
            'name' => 'B5',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $userA->id,
            'media_type' => 'video',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/'.$userA->id.'/video/test-priority.mp4',
            'original_name' => 'test-priority.mp4',
            'mime_type' => 'video/mp4',
            'size_bytes' => 4096,
            'width' => 1280,
            'height' => 720,
            'duration_ms' => 5000,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/chat-media/'.$userA->id.'/video/test-priority.mp4',
            'metadata' => ['kind' => 'video'],
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'video caption should not win',
            'attachment_ids' => [$asset->id],
        ])->assertOk()->assertJsonPath('ok', true);

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/conversations')
            ->assertOk()
            ->assertJsonPath('items.0.last_message', '视频消息');
    }

    public function test_list_auto_marks_incoming_messages_as_read(): void
    {
        $userA = User::create([
            'phone' => '13800000013',
            'name' => 'A2',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000014',
            'name' => 'B2',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'auto read check',
        ])->assertOk()->json();
        $messageId = (int) $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.is_read', true);
    }
}
