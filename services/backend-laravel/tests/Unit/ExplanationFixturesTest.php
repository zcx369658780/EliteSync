<?php

namespace Tests\Unit;

use Tests\TestCase;

class ExplanationFixturesTest extends TestCase
{
    public function test_explanation_fixture_has_at_least_forty_cases_and_required_keys(): void
    {
        $path = base_path('tests/Fixtures/explanations/explanation_cases_20.json');
        $this->assertFileExists($path);

        $raw = file_get_contents($path);
        $this->assertNotFalse($raw);
        $data = json_decode((string) $raw, true);
        $this->assertIsArray($data);
        $this->assertGreaterThanOrEqual(40, count($data));

        $required = [
            'case_id',
            'module_key',
            'summary',
            'process',
            'risks',
            'advice',
            'core_evidence',
            'supporting_evidence',
            'confidence',
            'priority',
        ];

        foreach ($data as $idx => $row) {
            $this->assertIsArray($row, "fixture row {$idx} should be object");
            foreach ($required as $key) {
                $this->assertArrayHasKey($key, $row, "fixture row {$idx} missing key {$key}");
            }
            $this->assertIsArray($row['process']);
            $this->assertIsArray($row['risks']);
            $this->assertIsArray($row['advice']);
            $this->assertIsArray($row['core_evidence']);
            $this->assertIsArray($row['supporting_evidence']);
        }
    }
}
