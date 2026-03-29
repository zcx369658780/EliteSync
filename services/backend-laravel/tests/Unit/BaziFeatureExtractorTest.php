<?php

namespace Tests\Unit;

use App\Services\AstroCompatibilityService;
use App\Services\BaziFeatureExtractor;
use Tests\TestCase;

class BaziFeatureExtractorTest extends TestCase
{
    public function test_extract_pair_features_returns_three_layer_scores(): void
    {
        $svc = app(BaziFeatureExtractor::class);
        $features = $svc->extractPairFeatures(
            '甲子年 丙寅月 丁卯日 庚午时',
            '乙丑年 丁卯月 己巳日 壬申时',
            [
                'wu_xing' => ['木' => 2, '火' => 3, '土' => 2, '金' => 1, '水' => 2],
                'liu_nian' => [2026, 2027, 2028],
            ],
            [
                'wu_xing' => ['木' => 1, '火' => 3, '土' => 3, '金' => 2, '水' => 1],
                'liu_nian' => [2027, 2028, 2029],
            ]
        );

        $this->assertTrue((bool) ($features['available'] ?? false));
        $this->assertGreaterThanOrEqual(0, (float) $features['structure_score']);
        $this->assertLessThanOrEqual(100, (float) $features['structure_score']);
        $this->assertGreaterThanOrEqual(0, (float) $features['relationship_score']);
        $this->assertLessThanOrEqual(100, (float) $features['relationship_score']);
        $this->assertGreaterThanOrEqual(0, (float) $features['timing_score']);
        $this->assertLessThanOrEqual(100, (float) $features['timing_score']);
        $this->assertIsArray($features['evidence_tags']);
        $this->assertIsArray($features['evidence']);
    }

    public function test_bazi_score_uses_feature_layer_when_wuxing_complete(): void
    {
        $astro = app(AstroCompatibilityService::class);
        $score = $astro->score(
            [
                'zodiac_animal' => '马',
                'public_zodiac_sign' => '巨蟹座',
                'private_bazi' => '甲子年 丙寅月 丁卯日 庚午时',
                'private_natal_chart' => [
                    'wu_xing' => ['木' => 2, '火' => 3, '土' => 2, '金' => 1, '水' => 2],
                    'liu_nian' => [2026, 2027, 2028],
                ],
                'birthday' => '1990-01-01',
                'gender' => 'female',
            ],
            [
                'zodiac_animal' => '龙',
                'public_zodiac_sign' => '天蝎座',
                'private_bazi' => '乙丑年 丁卯月 己巳日 壬申时',
                'private_natal_chart' => [
                    'wu_xing' => ['木' => 1, '火' => 3, '土' => 3, '金' => 2, '水' => 1],
                    'liu_nian' => [2027, 2028, 2029],
                ],
                'birthday' => '1988-02-02',
                'gender' => 'male',
            ]
        );

        $bazi = (array) data_get($score, 'module_details.bazi', []);
        $this->assertNotEmpty($bazi);
        $this->assertContains('bazi_feature_extractor_v1', (array) ($bazi['evidence_tags'] ?? []));
        $this->assertArrayHasKey('wu_xing', (array) ($bazi['evidence'] ?? []));
        $this->assertArrayHasKey('relationship', (array) ($bazi['evidence'] ?? []));
        $this->assertArrayHasKey('timing', (array) ($bazi['evidence'] ?? []));
    }
}

