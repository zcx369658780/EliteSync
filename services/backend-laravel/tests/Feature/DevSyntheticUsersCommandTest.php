<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\StatusPost;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class DevSyntheticUsersCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_synthetic_users_command_sets_account_layer_fields(): void
    {
        $code = Artisan::call('app:dev:synthetic-users', [
            '--count' => 2,
            '--batch' => 'test_batch',
            '--with-answers' => 0,
            '--password' => 'secret123',
            '--phone-prefix' => 90,
            '--cities' => '北京,上海',
            '--min-age' => 24,
            '--max-age' => 24,
        ]);

        $this->assertSame(0, $code);

        $users = User::query()
            ->where('synthetic_batch', 'test_batch')
            ->orderBy('id')
            ->get();

        $this->assertCount(2, $users);
        foreach ($users as $user) {
            $this->assertTrue((bool) $user->is_synthetic);
            $this->assertSame('user', $user->role);
            $this->assertSame('test', $user->account_type);
            $this->assertTrue((bool) $user->is_match_eligible);
            $this->assertTrue((bool) $user->is_square_visible);
            $this->assertTrue((bool) $user->exclude_from_metrics);
        }

        $posts = StatusPost::query()
            ->whereIn('author_user_id', $users->pluck('id')->all())
            ->orderBy('id')
            ->get();

        $this->assertCount(2, $posts);
        foreach ($posts as $post) {
            $this->assertSame('public', $post->visibility);
            $this->assertFalse((bool) $post->is_deleted);
            $this->assertNotEmpty($post->title);
            $this->assertNotEmpty($post->body);
        }
    }
}
