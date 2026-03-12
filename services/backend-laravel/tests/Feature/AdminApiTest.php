<?php

namespace Tests\Feature;

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
}
