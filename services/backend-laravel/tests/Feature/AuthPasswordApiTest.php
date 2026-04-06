<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthPasswordApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_change_password_success_and_login_with_new_password(): void
    {
        $user = User::create([
            'phone' => '13800000911',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'secret123',
            'new_password' => 'newpass123',
            'new_password_confirmation' => 'newpass123',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/auth/login', [
            'phone' => '13800000911',
            'password' => 'newpass123',
        ])->assertOk()->assertJsonStructure(['access_token', 'user' => ['id', 'phone']]);
    }

    public function test_change_password_rejects_wrong_current_password(): void
    {
        $user = User::create([
            'phone' => '13800000912',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'wrong123',
            'new_password' => 'newpass123',
            'new_password_confirmation' => 'newpass123',
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'validation_error');
    }

    public function test_change_password_rejects_weak_new_password(): void
    {
        $user = User::create([
            'phone' => '13800000913',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/auth/password', [
            'current_password' => 'secret123',
            'new_password' => '12345678',
            'new_password_confirmation' => '12345678',
        ])->assertStatus(422)
            ->assertJsonPath('error.code', 'validation_error');
    }

    public function test_delete_self_only_allows_smoke_accounts(): void
    {
        $smokeUser = User::create([
            'phone' => '90123456789',
            'name' => 'SmokeUser',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($smokeUser);

        $this->deleteJson('/api/v1/auth/account', [
            'current_password' => 'secret123',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->assertDatabaseMissing('users', [
            'phone' => '90123456789',
        ]);

        $realUser = User::create([
            'phone' => '13800000914',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($realUser);

        $this->deleteJson('/api/v1/auth/account', [
            'current_password' => 'secret123',
        ])->assertStatus(403);
    }
}
