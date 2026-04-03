<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AstroCanonicalApiTest extends TestCase
{
    use RefreshDatabase;

    private function fakePythonAstroService(): void
    {
        Http::fake([
            'http://127.0.0.1:8002/api/v1/profile/astro/render*' => Http::response([
                'ok' => true,
                'profile' => [
                    'natal_chart_svg' => '<svg xmlns="http://www.w3.org/2000/svg"></svg>',
                    'planets_data' => [
                        ['key' => 'sun', 'name' => '太阳', 'sign' => '狮子座', 'house' => '1'],
                    ],
                    'houses_data' => [
                        ['index' => 1, 'name' => '1宫', 'sign' => '白羊座'],
                        ['index' => 2, 'name' => '2宫', 'sign' => '金牛座'],
                        ['index' => 3, 'name' => '3宫', 'sign' => '双子座'],
                        ['index' => 4, 'name' => '4宫', 'sign' => '巨蟹座'],
                        ['index' => 5, 'name' => '5宫', 'sign' => '狮子座'],
                        ['index' => 6, 'name' => '6宫', 'sign' => '处女座'],
                        ['index' => 7, 'name' => '7宫', 'sign' => '天秤座'],
                        ['index' => 8, 'name' => '8宫', 'sign' => '天蝎座'],
                        ['index' => 9, 'name' => '9宫', 'sign' => '射手座'],
                        ['index' => 10, 'name' => '10宫', 'sign' => '摩羯座'],
                        ['index' => 11, 'name' => '11宫', 'sign' => '水瓶座'],
                        ['index' => 12, 'name' => '12宫', 'sign' => '双鱼座'],
                    ],
                    'aspects_data' => [
                        ['p1_name' => '太阳', 'p2_name' => '月亮', 'aspect' => '合相'],
                    ],
                    'chart_data' => ['subject' => ['name' => 'EliteSync']],
                    'generated_at' => '2026-04-02T00:00:00Z',
                ],
            ], 200),
        ]);
    }

    public function test_astro_save_uses_server_canonical_engine_without_client_sun_sign(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001101',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $res = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            // intentionally omit sun_sign to verify server-side canonical generation
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('profile.birth_time', '10:30')
            ->assertJsonPath('profile.sun_sign', '狮子座')
            ->assertJsonPath('profile.accuracy', 'canonical_server')
            ->assertJsonPath('profile.western_engine', 'legacy_input')
            ->assertJsonPath('profile.western_precision', 'legacy_estimate');

        $this->assertNotSame('10:30', (string) data_get($res->json(), 'profile.true_solar_time'));
        $this->assertNotEmpty(data_get($res->json(), 'profile.true_solar_time'));
        $this->assertSame('河南南阳', data_get($res->json(), 'profile.birth_place'));
        $this->assertNotNull(data_get($res->json(), 'profile.location_shift_minutes'));
        $this->assertNotNull(data_get($res->json(), 'profile.longitude_offset_minutes'));
        $this->assertNotNull(data_get($res->json(), 'profile.equation_of_time_minutes'));
        $this->assertNotEmpty((string) data_get($res->json(), 'profile.position_signature'));

        $this->assertIsString(data_get($res->json(), 'profile.natal_chart_svg'));
        $this->assertStringContainsString('<svg', (string) data_get($res->json(), 'profile.natal_chart_svg'));

        $user->refresh();
        $this->assertNotEmpty($user->private_bazi);
        $this->assertNotEmpty($user->zodiac_animal);
        $this->assertSame('狮子座', $user->public_zodiac_sign);
        $this->assertIsArray($user->private_ziwei);
        $this->assertNotEmpty($user->private_ziwei);
    }

    public function test_astro_save_changes_bazi_ziwei_and_western_when_birth_place_changes(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001103',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $first = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '北京市海淀区中关村',
            'birth_lat' => 39.98,
            'birth_lng' => 116.31,
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk();

        $firstProfile = (array) data_get($first->json(), 'profile', []);
        $this->assertNotEmpty($firstProfile);

        $second = $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '10:30',
            'birth_place' => '新疆维吾尔自治区乌鲁木齐市天山区',
            'birth_lat' => 43.8256,
            'birth_lng' => 87.6168,
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
        ])->assertOk();

        $secondProfile = (array) data_get($second->json(), 'profile', []);
        $this->assertNotEmpty($secondProfile);

        $this->assertNotSame(
            (string) ($firstProfile['true_solar_time'] ?? ''),
            (string) ($secondProfile['true_solar_time'] ?? '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['bazi'] ?? ''),
            (string) ($secondProfile['bazi'] ?? '')
        );
        $this->assertNotSame(
            (string) data_get($firstProfile, 'ziwei.life_palace', ''),
            (string) data_get($secondProfile, 'ziwei.life_palace', '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['moon_sign'] ?? ''),
            (string) ($secondProfile['moon_sign'] ?? '')
        );
        $this->assertNotSame(
            (string) ($firstProfile['asc_sign'] ?? ''),
            (string) ($secondProfile['asc_sign'] ?? '')
        );
        $this->assertNotSame(
            (int) ($firstProfile['location_shift_minutes'] ?? 0),
            (int) ($secondProfile['location_shift_minutes'] ?? 0)
        );
        $this->assertNotSame(
            (string) ($firstProfile['position_signature'] ?? ''),
            (string) ($secondProfile['position_signature'] ?? '')
        );
        $this->assertStringContainsString('<svg', (string) data_get($second->json(), 'profile.natal_chart_svg'));
    }

    public function test_astro_save_falls_back_when_user_birthday_missing(): void
    {
        $this->fakePythonAstroService();

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

    public function test_astro_summary_endpoint_returns_profile_without_svg_payload(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001104',
            'password' => 'secret123',
            'birthday' => '1996-08-18',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '09:20',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            'moon_sign' => '金牛座',
            'asc_sign' => '白羊座',
        ])->assertOk();

        Http::preventStrayRequests();

        $this->getJson('/api/v1/profile/astro/summary')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonMissingPath('profile.natal_chart_svg')
            ->assertJsonPath('profile.birthday', '1996-08-18')
            ->assertJsonPath('profile.birth_place', '河南南阳')
            ->assertJsonPath('profile.accuracy', 'canonical_server');
    }

    public function test_astro_chart_endpoint_returns_svg_payload(): void
    {
        $this->fakePythonAstroService();

        $user = User::create([
            'phone' => '13800001105',
            'password' => 'secret123',
            'birthday' => '1992-06-16',
            'gender' => 'male',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/astro', [
            'birth_time' => '11:10',
            'birth_place' => '北京市朝阳区',
            'birth_lat' => 39.9219,
            'birth_lng' => 116.4436,
            'moon_sign' => '天秤座',
            'asc_sign' => '双子座',
        ])->assertOk();

        $this->getJson('/api/v1/profile/astro/chart')
            ->assertOk()
            ->assertJsonPath('exists', true)
            ->assertJsonPath('profile.birthday', '1992-06-16')
            ->assertJsonPath('profile.birth_place', '北京市朝阳区')
            ->assertJsonPath('profile.natal_chart_svg', '<svg xmlns="http://www.w3.org/2000/svg"></svg>');
    }
}
