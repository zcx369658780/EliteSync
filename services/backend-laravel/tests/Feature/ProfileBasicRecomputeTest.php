<?php

namespace Tests\Feature;

use App\Models\User;
use App\Models\UserAstroProfile;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ProfileBasicRecomputeTest extends TestCase
{
    use RefreshDatabase;

    public function test_save_basic_recomputes_existing_astro_profile_with_new_birth_place(): void
    {
        $user = User::create([
            'phone' => '13800001105',
            'password' => 'secret123',
            'birthday' => '1995-05-12',
            'gender' => 'male',
            'city' => '南阳市',
            'relationship_goal' => 'dating',
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '09:30',
            'birth_place' => '河南南阳',
            'birth_lat' => 33.01,
            'birth_lng' => 112.53,
            'sun_sign' => '金牛座',
            'moon_sign' => '天蝎座',
            'asc_sign' => '狮子座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
            'true_solar_time' => '09:28',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_canonical_server'],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1996-06-13',
            'birth_time' => '10:45',
            'gender' => 'male',
            'city' => '武汉市',
            'relationship_goal' => 'dating',
            'birth_place' => '湖北省武汉市武昌区八一路299号',
            'birth_lat' => 30.5431,
            'birth_lng' => 114.3628,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '湖北省武汉市武昌区八一路299号')
            ->assertJsonPath('astro_profile.birth_time', '10:45')
            ->assertJsonPath('user.birthday', '1996-06-13')
            ->assertJsonPath('user.birth_time', '10:45')
            ->assertJsonPath('user.birth_place', '湖北省武汉市武昌区八一路299号');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('10:45', $profile->birth_time);
        $this->assertSame('湖北省武汉市武昌区八一路299号', $profile->birth_place);
        $this->assertSame(30.5431, (float) $profile->birth_lat);
        $this->assertSame(114.3628, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->notes);

        $user->refresh();
        $this->assertSame('1996-06-13', optional($user->birthday)->format('Y-m-d'));
        $this->assertSame('湖北省武汉市武昌区八一路299号', $user->private_birth_place);
        $this->assertSame(30.5431, (float) $user->private_birth_lat);
        $this->assertSame(114.3628, (float) $user->private_birth_lng);
        $this->assertNotEmpty($user->private_ziwei);
        $this->assertNotEmpty($user->private_natal_chart);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '10:45')
            ->assertJsonPath('birth_place', '湖北省武汉市武昌区八一路299号')
            ->assertJsonPath('birth_lat', 30.5431)
            ->assertJsonPath('birth_lng', 114.3628);
    }

    public function test_save_basic_bootstraps_astro_profile_when_missing(): void
    {
        $user = User::create([
            'phone' => '13800001106',
            'password' => 'secret123',
            'birthday' => '1994-04-18',
            'gender' => 'female',
            'city' => '深圳市',
            'relationship_goal' => 'marriage',
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1994-04-19',
            'birth_time' => '08:15',
            'gender' => 'female',
            'city' => '深圳市',
            'relationship_goal' => 'marriage',
            'birth_place' => '广东省深圳市南山区深南大道',
            'birth_lat' => 22.5431,
            'birth_lng' => 113.9304,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '广东省深圳市南山区深南大道')
            ->assertJsonPath('astro_profile.birth_time', '08:15')
            ->assertJsonPath('user.birth_time', '08:15')
            ->assertJsonPath('user.birth_place', '广东省深圳市南山区深南大道');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('08:15', $profile->birth_time);
        $this->assertSame('广东省深圳市南山区深南大道', $profile->birth_place);
        $this->assertSame(22.5431, (float) $profile->birth_lat);
        $this->assertSame(113.9304, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->bazi);

        $user->refresh();
        $this->assertSame('广东省深圳市南山区深南大道', $user->private_birth_place);
        $this->assertNotEmpty($user->private_bazi);
        $this->assertNotEmpty($user->private_ziwei);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '08:15')
            ->assertJsonPath('birth_place', '广东省深圳市南山区深南大道')
            ->assertJsonPath('birth_lat', 22.5431)
            ->assertJsonPath('birth_lng', 113.9304);
    }

    public function test_save_basic_changes_astro_when_birth_place_changes_with_same_birth_time(): void
    {
        $user = User::create([
            'phone' => '13800001107',
            'password' => 'secret123',
            'birthday' => '1996-06-13',
            'gender' => 'male',
            'city' => '上海市',
            'relationship_goal' => 'dating',
        ]);

        UserAstroProfile::create([
            'user_id' => $user->id,
            'birth_time' => '10:45',
            'birth_place' => '上海市黄浦区人民大道200号',
            'birth_lat' => 31.2304,
            'birth_lng' => 121.4737,
            'sun_sign' => '双子座',
            'moon_sign' => '双鱼座',
            'asc_sign' => '处女座',
            'bazi' => '甲子 乙丑 丙寅 丁卯',
            'true_solar_time' => '10:45',
            'da_yun' => [],
            'liu_nian' => [],
            'wu_xing' => [],
            'ziwei' => ['engine' => 'ziwei_canonical_server', 'life_palace' => '命宫'],
            'notes' => ['canonical_accuracy:canonical_server'],
            'computed_at' => now()->subDay(),
        ]);

        Sanctum::actingAs($user);

        $this->postJson('/api/v1/profile/basic', [
            'birthday' => '1996-06-13',
            'birth_time' => '10:45',
            'gender' => 'male',
            'city' => '上海市',
            'relationship_goal' => 'dating',
            'birth_place' => '新疆维吾尔自治区乌鲁木齐市天山区人民广场',
            'birth_lat' => 43.8256,
            'birth_lng' => 87.6168,
        ])->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('astro_profile.birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场')
            ->assertJsonPath('astro_profile.birth_time', '10:45')
            ->assertJsonPath('user.birth_time', '10:45')
            ->assertJsonPath('user.birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场');

        $profile = UserAstroProfile::query()->where('user_id', $user->id)->firstOrFail();
        $this->assertSame('10:45', $profile->birth_time);
        $this->assertSame('新疆维吾尔自治区乌鲁木齐市天山区人民广场', $profile->birth_place);
        $this->assertSame(43.8256, (float) $profile->birth_lat);
        $this->assertSame(87.6168, (float) $profile->birth_lng);
        $this->assertNotEmpty($profile->true_solar_time);
        $this->assertNotSame('10:45', $profile->true_solar_time);
        $this->assertNotSame('甲子 乙丑 丙寅 丁卯', $profile->bazi);
        $this->assertNotSame('命宫', data_get($profile->ziwei, 'life_palace'));
        $this->assertNotSame('处女座', $profile->asc_sign);

        $user->refresh();
        $this->assertSame('新疆维吾尔自治区乌鲁木齐市天山区人民广场', $user->private_birth_place);
        $this->assertNotSame('甲子 乙丑 丙寅 丁卯', $user->private_bazi);
        $this->assertNotEmpty($user->private_ziwei);

        $this->getJson('/api/v1/profile/basic')
            ->assertOk()
            ->assertJsonPath('birth_time', '10:45')
            ->assertJsonPath('birth_place', '新疆维吾尔自治区乌鲁木齐市天山区人民广场')
            ->assertJsonPath('birth_lat', 43.8256)
            ->assertJsonPath('birth_lng', 87.6168);
    }
}
