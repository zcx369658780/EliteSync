<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_verify_queue_and_update_flow(): void
    {
        $admin = User::create([
            'phone' => '13800000101',
            'name' => 'admin',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        $pendingUser = User::create([
            'phone' => '13800000102',
            'name' => 'pending',
            'password' => 'secret123',
            'verify_status' => 'pending',
        ]);

        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/admin/verify-queue')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $pendingUser->id);

        $this->postJson('/api/v1/admin/verify/'.$pendingUser->id, [
            'status' => 'approved',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/admin/users/'.$pendingUser->id.'/disable')
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/admin/users')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $pendingUser->id,
                'verify_status' => 'approved',
                'disabled' => true,
            ]);
    }

    public function test_dev_matching_and_release_drop_flow(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000111',
            'name' => 'admin',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        $u1 = User::create([
            'phone' => '13800000112',
            'name' => 'u1',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        User::create([
            'phone' => '13800000113',
            'name' => 'u2',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        $incomplete = User::create([
            'phone' => '13800000114',
            'name' => 'u3',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        Sanctum::actingAs($admin);

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                ['question_id' => 1, 'answer' => 'A'],
                ['question_id' => 2, 'answer' => 'B'],
                ['question_id' => 3, 'answer' => 'A'],
            ],
        ])->assertOk();
        Sanctum::actingAs($u1);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                ['question_id' => 1, 'answer' => 'A'],
                ['question_id' => 2, 'answer' => 'B'],
                ['question_id' => 3, 'answer' => 'A'],
            ],
        ])->assertOk();
        Sanctum::actingAs($admin);

        $run = $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->json();

        $this->assertGreaterThanOrEqual(1, (int) ($run['pairs'] ?? 0));
        $this->assertSame(2, (int) ($run['eligible_users'] ?? 0));

        $this->postJson('/api/v1/admin/dev/release-drop')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('released', 1);

        $this->assertFalse(
            DatingMatch::query()
                ->where('user_a', $incomplete->id)
                ->orWhere('user_b', $incomplete->id)
                ->exists()
        );
    }
}
