<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AstroCanonicalApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_astro_save_uses_server_canonical_engine_without_client_sun_sign(): void
    {
        $user = User::create([
            'phone' => '13800001101',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            // intentionally omit sun_sign to verify server-side canonical generation
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.sun_sign', '狮子座')
            ->assertJsonPath('profile.accuracy', 'canonical_server')
            ->assertJsonPath('profile.western_engine', 'legacy_input')
            ->assertJsonPath('profile.western_precision', 'legacy_estimate');

        $user->refresh();
        $this->assertNotEmpty($user->private_bazi);
        $this->assertNotEmpty($user->zodiac_animal);
        $this->assertSame('狮子座', $user->public_zodiac_sign);
    }

    public function test_astro_save_falls_back_when_user_birthday_missing(): void
    {
        $user = User::create([
            'phone' => '13800001102',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '08:15',
            'sun_sign' => '双鱼座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
        ])->assertOk()
            ->assertJsonPath('ok', true);

        $notes = (array) data_get($res->json(), 'profile.notes', []);
        $this->assertTrue(
            collect($notes)->contains(fn ($n) => str_contains((string) $n, 'canonical_fallback')),
            'fallback marker should exist in notes'
        );
    }
}
