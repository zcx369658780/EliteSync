<?php

namespace Tests\Unit;

use App\Services\BaziDerivedZodiacService;
use App\Services\ChineseZodiacService;
use Tests\TestCase;

class ZodiacDerivationTest extends TestCase
{
    public function test_bazi_year_pillar_derivation_basic_cases(): void
    {
        $svc = app(BaziDerivedZodiacService::class);

        $this->assertSame('鼠', $svc->fromYearPillar('甲子'));
        $this->assertSame('龙', $svc->fromYearPillar('戊辰'));
        $this->assertSame('猪', $svc->fromYearPillar('辛亥'));
        $this->assertNull($svc->fromYearPillar(''));
        $this->assertNull($svc->fromYearPillar('invalid'));
    }

    public function test_preferred_source_uses_bazi_first(): void
    {
        $svc = app(ChineseZodiacService::class);

        $this->assertSame('鼠', $svc->fromPreferredSources('甲子年 丙寅月 丁卯日 庚午时', '1990-06-01'));
        $this->assertSame('马', $svc->fromPreferredSources(null, '1990-06-01'));
    }

    public function test_zodiac_vectors_file(): void
    {
        $svc = app(ChineseZodiacService::class);

        $repoRoot = dirname(dirname(base_path()));
        $vectorsFile = $repoRoot.DIRECTORY_SEPARATOR.'bazi_example'.DIRECTORY_SEPARATOR.'test_vectors'.DIRECTORY_SEPARATOR.'zodiac_boundary_vectors.json';
        $this->assertFileExists($vectorsFile);

        $json = file_get_contents($vectorsFile);
        $this->assertNotFalse($json);

        $vectors = json_decode((string) $json, true);
        $this->assertIsArray($vectors);
        $this->assertNotEmpty($vectors);

        foreach ($vectors as $case) {
            $id = (string) ($case['id'] ?? 'unknown');
            $input = (array) ($case['input'] ?? []);
            $expected = (string) ($case['expected'] ?? '');

            $actual = $svc->fromPreferredSources(
                (string) ($input['bazi'] ?? ''),
                isset($input['birthday']) ? (string) $input['birthday'] : null
            );

            $this->assertSame($expected, $actual, "case={$id}");
        }
    }
}
