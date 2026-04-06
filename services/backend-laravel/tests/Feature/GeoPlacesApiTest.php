<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Illuminate\Support\Facades\Http;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class GeoPlacesApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_geo_places_search_returns_baidu_suggestions(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 0,
                'result' => [
                    [
                        'name' => '武汉市',
                        'address' => '湖北省武汉市',
                        'city' => '武汉市',
                        'district' => '',
                        'location' => ['lat' => 30.5928, 'lng' => 114.3055],
                    ],
                    [
                        'name' => '武汉大学',
                        'address' => '湖北省武汉市武昌区八一路299号',
                        'city' => '武汉市',
                        'district' => '武昌区',
                        'location' => ['lat' => 30.5431, 'lng' => 114.3628],
                    ],
                ],
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001103',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/geo/places?query=%E6%AD%A6%E6%B1%89%E5%A4%A7%E5%AD%A6&region=%E6%AD%A6%E6%B1%89%E5%B8%82')
            ->assertOk()
            ->assertJsonPath('places.0.label', '武汉大学')
            ->assertJsonPath('places.0.city', '武汉市')
            ->assertJsonPath('places.0.district', '武昌区');

        Http::assertSent(function ($request) {
            $url = (string) $request->url();
            parse_str((string) parse_url($url, PHP_URL_QUERY), $query);
            return str_contains($url, '/place/v2/suggestion')
                && ($query['query'] ?? null) === '武汉大学'
                && !empty($query['sn'] ?? null)
                && ($query['ak'] ?? null) === 'test-web-ak';
        });
    }

    public function test_geo_places_search_prefers_exact_match_first(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 0,
                'result' => [
                    [
                        'name' => '武汉市',
                        'address' => '湖北省武汉市',
                        'city' => '武汉市',
                        'district' => '',
                        'location' => ['lat' => 30.5928, 'lng' => 114.3055],
                    ],
                    [
                        'name' => '武汉大学',
                        'address' => '湖北省武汉市武昌区八一路299号',
                        'city' => '武汉市',
                        'district' => '武昌区',
                        'location' => ['lat' => 30.5431, 'lng' => 114.3628],
                    ],
                ],
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001104',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $res = $this->getJson('/api/v1/geo/places?query=%E6%AD%A6%E6%B1%89%E5%A4%A7%E5%AD%A6&region=%E6%AD%A6%E6%B1%89%E5%B8%82')
            ->assertOk()
            ->json('places');

        $this->assertSame('武汉大学', $res[0]['label']);
        $this->assertSame('武汉市', $res[1]['label']);
    }

    public function test_geo_places_search_returns_clear_error_when_baidu_service_disabled(): void
    {
        Config::set('baidu.web_ak', 'test-web-ak');
        Config::set('baidu.web_sk', 'test-web-sk');

        Http::fake([
            'https://api.map.baidu.com/place/v2/suggestion*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
            'https://api.map.baidu.com/place/v2/search*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
            'https://api.map.baidu.com/geocoding/v3*' => Http::response([
                'status' => 240,
                'message' => 'APP 服务被禁用',
            ], 200),
        ]);

        $user = User::create([
            'phone' => '13800001107',
            'password' => 'secret123',
            'gender' => 'female',
        ]);

        Sanctum::actingAs($user);

        $this->getJson('/api/v1/geo/places?query=%E5%8D%97%E9%98%B3&region=%E5%85%A8%E5%9B%BD')
            ->assertStatus(503)
            ->assertJsonPath('places', [])
            ->assertJsonPath('message', '百度地点服务未启用或已被禁用，请在百度控制台开启 Place/Geocoding 服务');
    }
}
