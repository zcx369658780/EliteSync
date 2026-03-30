<?php

namespace Tests\Unit;

use App\Support\ExplanationMetaBuilder;
use Tests\TestCase;

class ExplanationMetaBuilderTest extends TestCase
{
    public function test_build_degraded_module_has_strict_display_guard(): void
    {
        $builder = new ExplanationMetaBuilder();
        $meta = $builder->build([
            'confidence' => 0.92,
            'degraded' => true,
            'degrade_reason' => 'date_only',
            'evidence_tags' => ['missing_bazi'],
            'evidence' => [
                'engine_source' => 'legacy_estimate',
            ],
        ]);

        $this->assertSame('legacy_estimate', $meta['engine_source']);
        $this->assertSame('legacy', $meta['engine_mode']);
        $this->assertSame('date_only', $meta['data_quality']);
        $this->assertFalse($meta['display_guard']['allow_high_confidence_badge']);
        $this->assertFalse($meta['display_guard']['allow_strong_evidence_badge']);
        $this->assertFalse($meta['display_guard']['allow_precise_wording']);
    }

    public function test_build_canonical_module_can_get_high_confidence_badge(): void
    {
        $builder = new ExplanationMetaBuilder();
        $meta = $builder->build([
            'confidence' => 0.9,
            'degraded' => false,
            'engine_source' => 'lunar_php',
            'engine_mode' => 'canonical',
            'data_quality' => 'exact_time+location',
            'precision_level' => 'high',
            'core_tags' => ['五行互补', '地支六合'],
            'evidence_tags' => ['wu_xing_complement', 'bazi_branch_liuhe'],
        ]);

        $this->assertTrue($meta['display_guard']['allow_high_confidence_badge']);
        $this->assertTrue($meta['display_guard']['allow_strong_evidence_badge']);
        $this->assertTrue($meta['display_guard']['allow_precise_wording']);
        $this->assertSame('high', $meta['confidence_tier']);
    }
}

