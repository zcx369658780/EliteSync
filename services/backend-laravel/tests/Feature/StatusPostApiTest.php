<?php

namespace Tests\Feature;

use App\Models\StatusPost;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
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
}
