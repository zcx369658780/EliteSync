<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\MediaAsset;
use App\Models\ModerationReport;
use App\Models\UserBlock;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class StatusPostApiTest extends TestCase
{
    use RefreshDatabase;

    private function makeUser(array $overrides = []): User
    {
        return User::create(array_merge([
            'name' => 'SmokeUser',
            'phone' => '17000000000',
            'password' => 'password',
            'role' => 'user',
            'account_type' => 'normal',
            'verify_status' => 'approved',
            'realname_verified' => true,
            'disabled' => false,
            'moderation_status' => 'normal',
            'is_synthetic' => false,
            'synthetic_batch' => null,
            'is_match_eligible' => true,
            'is_square_visible' => true,
            'exclude_from_metrics' => false,
            'banned_reason' => null,
            'birthday' => '1996-08-18',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ], $overrides));
    }

    public function test_store_list_and_delete_status_post(): void
    {
        $user = $this->makeUser([
            'phone' => '17000000001',
            'account_type' => 'test',
            'is_synthetic' => true,
        ]);

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/status/posts', [
                'title' => '今晚想散步',
                'body' => '在南阳找个轻松话题开始聊天。',
            ])
            ->assertCreated()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('item.title', '今晚想散步');

        $this->actingAs($user, 'sanctum')
            ->getJson('/api/v1/status/posts')
            ->assertOk()
            ->assertJsonPath('items.0.title', '今晚想散步')
            ->assertJsonPath('items.0.author.is_synthetic', true)
            ->assertJsonPath('items.0.author.account_type', 'test');

        $postId = (int) StatusPost::query()->firstOrFail()->id;

        $this->actingAs($user, 'sanctum')
            ->deleteJson("/api/v1/status/posts/{$postId}")
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertTrue((bool) StatusPost::query()->firstOrFail()->is_deleted);
    }

    public function test_admin_can_delete_any_status_post(): void
    {
        $author = $this->makeUser(['phone' => '17000000002']);
        $admin = $this->makeUser([
            'phone' => '17000000099',
            'role' => 'admin',
            'account_type' => 'normal',
        ]);

        $post = StatusPost::create([
            'author_user_id' => (int) $author->id,
            'title' => '测试状态',
            'body' => '管理员可删除。',
            'location_name' => '南阳',
            'visibility' => 'public',
            'is_deleted' => false,
        ]);

        $this->actingAs($admin, 'sanctum')
            ->deleteJson("/api/v1/status/posts/{$post->id}")
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->assertTrue((bool) $post->fresh()->is_deleted);
    }

    public function test_single_image_status_like_report_and_author_page_flow(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'filesystems.disks.public.url' => 'http://101.133.161.203/storage',
        ]);

        $author = $this->makeUser([
            'phone' => '17000000003',
            'name' => 'Author',
        ]);
        $viewer = $this->makeUser([
            'phone' => '17000000004',
            'name' => 'Viewer',
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $author->id,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'status-media/'.$author->id.'/cover.jpg',
            'original_name' => 'cover.jpg',
            'mime_type' => 'image/jpeg',
            'size_bytes' => 1024,
            'status' => 'ready',
            'public_url' => 'http://localhost:8080/storage/status-media/'.$author->id.'/cover.jpg',
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        $expectedUrl = 'http://localhost:8080/api/v1/media/'.$asset->id.'/content';

        Sanctum::actingAs($author);
        $created = $this->postJson('/api/v1/status/posts', [
            'title' => '今晚想散步',
            'body' => '单图动态测试。',
            'cover_media_asset_id' => $asset->id,
        ])
            ->assertCreated()
            ->assertJsonPath('item.cover_media.public_url', $expectedUrl)
            ->json('item');

        $postId = (int) $created['id'];

        Sanctum::actingAs($viewer);
        $this->getJson('/api/v1/status/posts/'.$postId)
            ->assertOk()
            ->assertJsonPath('item.id', $postId)
            ->assertJsonPath('item.media.0', $expectedUrl);

        $this->postJson('/api/v1/status/posts/'.$postId.'/likes')
            ->assertOk()
            ->assertJsonPath('item.likes_count', 1)
            ->assertJsonPath('item.liked_by_viewer', true);

        $this->deleteJson('/api/v1/status/posts/'.$postId.'/likes')
            ->assertOk()
            ->assertJsonPath('item.likes_count', 0)
            ->assertJsonPath('item.liked_by_viewer', false);

        $this->postJson('/api/v1/status/posts/'.$postId.'/report', [
            'reason_code' => 'spam',
            'detail' => 'demo report',
        ])
            ->assertOk()
            ->assertJsonPath('report.status', 'new');

        $this->assertDatabaseHas('moderation_reports', [
            'target_user_id' => $author->id,
            'target_status_post_id' => $postId,
            'category' => 'status_post',
            'reason_code' => 'spam',
        ]);

        $this->getJson('/api/v1/status/authors/'.$author->id)
            ->assertOk()
            ->assertJsonPath('author.id', $author->id)
            ->assertJsonPath('items.0.id', $postId);
    }

    public function test_blocked_author_is_filtered_from_status_feed(): void
    {
        $viewer = $this->makeUser([
            'phone' => '17000000005',
            'name' => 'Viewer2',
        ]);
        $author = $this->makeUser([
            'phone' => '17000000006',
            'name' => 'BlockedAuthor',
        ]);

        StatusPost::create([
            'author_user_id' => (int) $author->id,
            'title' => '被屏蔽状态',
            'body' => '应该不会出现在 viewer 流里。',
            'location_name' => '南阳',
            'visibility' => 'public',
            'is_deleted' => false,
        ]);

        UserBlock::create([
            'blocker_id' => $viewer->id,
            'blocked_user_id' => $author->id,
        ]);

        Sanctum::actingAs($viewer);
        $this->getJson('/api/v1/status/posts')
            ->assertOk()
            ->assertJsonCount(0, 'items');
    }
}
