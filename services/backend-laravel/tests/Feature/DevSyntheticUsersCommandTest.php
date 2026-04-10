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
            '--batch-id' => 'test_batch_id',
            '--generation-version' => 'v32',
            '--visibility-scope' => 'square',
            '--seed' => 12345,
            '--with-answers' => 0,
            '--password' => 'secret123',
            '--phone-prefix' => 90,
            '--cities' => '北京,上海',
            '--min-age' => 24,
            '--max-age' => 24,
        ]);

        $this->assertSame(0, $code, Artisan::output());

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
            $this->assertSame('test_batch_id', $user->synthetic_batch_id);
            $this->assertSame('v32', $user->generation_version);
            $this->assertSame('active', $user->account_status);
            $this->assertSame('square', $user->visibility_scope);
            $this->assertNotEmpty($user->cleanup_token);
            $this->assertNotNull($user->synthetic_seed);
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

    public function test_synthetic_users_command_supports_summary_disable_and_cleanup(): void
    {
        Artisan::call('app:dev:synthetic-users', [
            '--count' => 3,
            '--batch' => 'ops_batch',
            '--batch-id' => 'ops_batch_id',
            '--with-answers' => 0,
            '--password' => 'secret123',
            '--phone-prefix' => 90,
            '--cities' => '北京,上海,广州',
            '--min-age' => 24,
            '--max-age' => 24,
            '--seed' => 24680,
        ]);

        $summaryCode = Artisan::call('app:dev:synthetic-users', [
            '--summary' => true,
            '--batch' => 'ops_batch',
        ]);
        $this->assertSame(0, $summaryCode, Artisan::output());

        $disableCode = Artisan::call('app:dev:synthetic-users', [
            '--disable-batch' => 'ops_batch',
        ]);
        $this->assertSame(0, $disableCode);

        $disabledUsers = User::query()
            ->where('synthetic_batch', 'ops_batch')
            ->orderBy('id')
            ->get();
        $this->assertCount(3, $disabledUsers);
        foreach ($disabledUsers as $user) {
            $this->assertTrue((bool) $user->disabled);
            $this->assertSame('disabled', $user->account_status);
            $this->assertSame('hidden', $user->visibility_scope);
            $this->assertFalse((bool) $user->is_match_eligible);
            $this->assertFalse((bool) $user->is_square_visible);
        }

        $cleanupCode = Artisan::call('app:dev:synthetic-users', [
            '--cleanup-batch' => 'ops_batch',
        ]);
        $this->assertSame(0, $cleanupCode);
        $this->assertSame(0, User::query()->where('synthetic_batch', 'ops_batch')->count());
    }

    public function test_synthetic_users_command_supports_rebuild_batch(): void
    {
        Artisan::call('app:dev:synthetic-users', [
            '--count' => 2,
            '--batch' => 'rebuild_batch',
            '--batch-id' => 'rebuild_batch_id',
            '--with-answers' => 0,
            '--password' => 'secret123',
            '--phone-prefix' => 90,
            '--cities' => '北京,上海',
            '--min-age' => 24,
            '--max-age' => 24,
            '--seed' => 100,
        ]);

        $initialPhones = User::query()
            ->where('synthetic_batch', 'rebuild_batch')
            ->orderBy('id')
            ->pluck('phone')
            ->all();

        $this->assertCount(2, $initialPhones);

        $rebuildCode = Artisan::call('app:dev:synthetic-users', [
            '--rebuild-batch' => 'rebuild_batch',
            '--count' => 2,
            '--batch-id' => 'rebuild_batch_id',
            '--with-answers' => 0,
            '--password' => 'secret123',
            '--phone-prefix' => 90,
            '--cities' => '北京,上海',
            '--min-age' => 24,
            '--max-age' => 24,
            '--seed' => 999,
        ]);
        $this->assertSame(0, $rebuildCode, Artisan::output());

        $rebuiltUsers = User::query()
            ->where('synthetic_batch', 'rebuild_batch')
            ->orderBy('id')
            ->get();

        $this->assertCount(2, $rebuiltUsers);
        $this->assertNotSame($initialPhones, $rebuiltUsers->pluck('phone')->all());
        $this->assertSame('rebuild_batch', $rebuiltUsers[0]->synthetic_batch_id);
        $this->assertSame(999, (int) $rebuiltUsers[0]->synthetic_seed);
    }
}
