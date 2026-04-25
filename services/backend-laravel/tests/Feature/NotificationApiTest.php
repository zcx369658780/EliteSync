<?php

namespace Tests\Feature;

use App\Models\AppNotificationItem;
use App\Models\User;
use App\Services\NotificationService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class NotificationApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_notifications_index_and_unread_count_and_mark_read_flow(): void
    {
        $user = User::create([
            'phone' => '13800000031',
            'name' => 'Notifier',
            'password' => 'secret123',
        ]);
        $other = User::create([
            'phone' => '13800000032',
            'name' => 'Peer',
            'password' => 'secret123',
        ]);

        AppNotificationItem::query()->create([
            'user_id' => $user->id,
            'kind' => 'message',
            'title' => 'Peer 发来一条消息',
            'body' => 'hello',
            'payload' => [
                'route_name' => 'chat_room',
                'route_args' => ['conversation_id' => (string) $other->id],
            ],
            'read_at' => null,
        ]);
        AppNotificationItem::query()->create([
            'user_id' => $user->id,
            'kind' => 'status_like',
            'title' => 'Peer 赞了你的动态',
            'body' => 'nice',
            'payload' => [
                'route_name' => 'status_author',
                'route_args' => ['user_id' => $other->id],
            ],
            'read_at' => now(),
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/notifications')
            ->assertOk()
            ->assertJsonPath('total', 2)
            ->assertJsonPath('unread_total', 1)
            ->assertJsonPath('items.0.kind', 'status_like')
            ->assertJsonPath('items.1.kind', 'message');

        $this->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('unread_total', 1);

        $notificationId = (int) AppNotificationItem::query()
            ->where('user_id', $user->id)
            ->where('kind', 'message')
            ->value('id');

        $this->postJson("/api/v1/notifications/{$notificationId}/read")
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/notifications/unread-count')
            ->assertOk()
            ->assertJsonPath('unread_total', 0);

        $otherNotificationId = (int) AppNotificationItem::query()
            ->where('user_id', $user->id)
            ->where('kind', 'status_like')
            ->value('id');

        $this->postJson('/api/v1/notifications/read-all')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('affected', 0);

        $this->assertDatabaseHas('notifications', [
            'id' => $otherNotificationId,
            'user_id' => $user->id,
            'kind' => 'status_like',
        ]);
    }

    public function test_create_for_user_deduplicates_same_payload_within_window(): void
    {
        $service = app(NotificationService::class);
        $user = User::create([
            'phone' => '13800000033',
            'name' => 'DedupUser',
            'password' => 'secret123',
        ]);

        $item1 = $service->createForUser(
            $user->id,
            'message',
            'Peer 发来一条消息',
            'hello',
            [
                'route_name' => 'chat_room',
                'route_args' => ['conversation_id' => '88'],
            ],
        );
        $item2 = $service->createForUser(
            $user->id,
            'message',
            'Peer 发来一条消息',
            'hello',
            [
                'route_name' => 'chat_room',
                'route_args' => ['conversation_id' => '88'],
            ],
        );

        $this->assertSame($item1->id, $item2->id);
        $this->assertSame(1, AppNotificationItem::query()->where('user_id', $user->id)->count());
    }
}
