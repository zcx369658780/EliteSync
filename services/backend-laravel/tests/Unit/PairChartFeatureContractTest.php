<?php

namespace Tests\Unit;

use App\Services\AstroCompatibilityService;
use Tests\TestCase;

class PairChartFeatureContractTest extends TestCase
{
    public function test_pair_chart_exposes_structured_features(): void
    {
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

        $pair = (array) data_get($result, 'module_details.pair_chart', []);
        $features = (array) data_get($pair, 'evidence.features', []);
        $this->assertNotEmpty($features);
        $this->assertContains('pair_chart_v2', (array) ($pair['evidence_tags'] ?? []));

        foreach ($features as $row) {
            $r = (array) $row;
            foreach (['key', 'label', 'score', 'weight', 'contribution', 'evidence_tags', 'evidence'] as $field) {
                $this->assertArrayHasKey($field, $r);
            }
            $this->assertIsArray($r['evidence_tags']);
            $this->assertIsArray($r['evidence']);
        }
    }
}

