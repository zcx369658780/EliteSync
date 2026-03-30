<?php

namespace Tests\Unit;

use App\Support\ExplanationComposer;
use App\Support\ExplanationTemplateRegistry;
use Tests\TestCase;

class ExplanationComposerTest extends TestCase
{
    public function test_compose_generates_four_layer_structure(): void
    {
        $composer = new ExplanationComposer(new ExplanationTemplateRegistry());
        $rows = $composer->compose([
            [
                'key' => 'bazi',
                'label' => '八字匹配',
                'reason' => '八字五行互补度较好',
                'risk' => '存在节律磨合点',
                'core_tags' => ['五行互补'],
                'aux_tags' => ['岁运节律同步'],
                'confidence_tier' => 'medium',
                'priority_level' => 'high',
                'priority_reason' => '风险等级高',
            ],
        ]);

        $this->assertCount(1, $rows);
        $first = $rows[0];
        $this->assertSame('bazi', $first['key']);
        $this->assertIsArray($first['process']);
        $this->assertIsArray($first['risks']);
        $this->assertIsArray($first['advice']);
        $this->assertNotEmpty($first['summary']);
    }
}

