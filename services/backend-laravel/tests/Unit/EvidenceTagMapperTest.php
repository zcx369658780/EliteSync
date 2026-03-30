<?php

namespace Tests\Unit;

use App\Support\EvidenceTagMapper;
use Tests\TestCase;

class EvidenceTagMapperTest extends TestCase
{
    public function test_normalize_and_map_display_labels(): void
    {
        $mapper = new EvidenceTagMapper([
            'wu_xing_complement' => ['label' => '五行互补'],
            'zodiac_liuhe' => ['label' => '属相六合'],
        ]);

        $tags = $mapper->normalizeTags([' Wu_Xing_Complement ', '', 'zodiac_liuhe', 'zodiac_liuhe']);
        $this->assertSame(['wu_xing_complement', 'zodiac_liuhe'], $tags);

        $labels = $mapper->toDisplayLabels($tags);
        $this->assertSame(['五行互补', '属相六合'], $labels);
    }
}

