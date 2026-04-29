<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
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
            'private_birth_place' => '广东省深圳市南山区',
            'private_birth_lat' => 22.5431,
            'private_birth_lng' => 114.0579,
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
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '广东省深圳市南山区')
            ->assertJsonPath('user.private_birth_place', '广东省深圳市南山区')
            ->assertJsonPath('user.birth_lat', 22.5431)
            ->assertJsonPath('user.birth_lng', 114.0579);
    }

    public function test_login_prefers_profile_birth_place_when_private_value_is_blank(): void
    {
        $user = User::create([
            'phone' => '13800000915',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'gender' => 'male',
            'city' => '南京市',
            'relationship_goal' => 'dating',
            'birth_place' => '江苏省南京市玄武区',
            'birth_lat' => 32.0603,
            'birth_lng' => 118.7969,
            'birth_time' => '12:00',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '江苏省南京市玄武区');

        $user->refresh();
        $user->private_birth_place = '';
        $user->save();

        UserAstroProfile::query()->where('user_id', $user->id)->update([
            'birth_place' => '江苏省南京市玄武区',
        ]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_place', '江苏省南京市玄武区');

        $this->postJson('/api/v1/auth/login', [
            'phone' => '13800000915',
            'password' => 'secret123',
        ])->assertOk()
            ->assertJsonPath('user.birth_place', '江苏省南京市玄武区')
            ->assertJsonPath('user.private_birth_place', '江苏省南京市玄武区')
            ->assertJsonPath('user.birth_lat', 32.0603)
            ->assertJsonPath('user.birth_lng', 118.7969);
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
