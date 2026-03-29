<?php

namespace Tests\Unit;

use App\Services\AstroCompatibilityService;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class WesternEngineSwitchTest extends TestCase
{
    public function test_western_engine_switch_to_standard_keeps_pair_feature_contract(): void
    {
        Config::set('matching.western_engine', 'standard');

        $svc = app(AstroCompatibilityService::class);
        $result = $svc->score(
            [
                'zodiac_animal' => '马',
                'public_zodiac_sign' => '巨蟹座',
                'private_bazi' => '甲子年 丙寅月 丁卯日 庚午时',
                'private_natal_chart' => [
                    'moon_sign' => '双鱼座',
                    'asc_sign' => '天秤座',
                    'wu_xing' => ['木' => 2, '火' => 3, '土' => 2, '金' => 1, '水' => 2],
                ],
                'birthday' => '1990-01-01',
                'gender' => 'female',
            ],
            [
                'zodiac_animal' => '龙',
                'public_zodiac_sign' => '天蝎座',
                'private_bazi' => '乙丑年 丁卯月 己巳日 壬申时',
                'private_natal_chart' => [
                    'moon_sign' => '巨蟹座',
                    'asc_sign' => '白羊座',
                    'wu_xing' => ['木' => 1, '火' => 3, '土' => 3, '金' => 2, '水' => 1],
                ],
                'birthday' => '1988-02-02',
                'gender' => 'male',
            ]
        );

        $pairEvidence = (array) data_get($result, 'module_details.pair_chart.evidence', []);
        $this->assertSame('standard_stub_v1', (string) ($pairEvidence['engine_source'] ?? ''));
        $this->assertIsArray((array) ($pairEvidence['features'] ?? []));
        $this->assertNotEmpty((array) ($pairEvidence['features'] ?? []));
    }
}

