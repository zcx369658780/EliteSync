<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use App\Services\ZiweiCanonicalService;
use Tests\TestCase;

class ZiweiCanonicalServiceTest extends TestCase
{
    public function test_canonicalize_returns_structured_ziwei_profile(): void
    {
        $service = new ZiweiCanonicalService(app(AstroCanonicalRolloutService::class));
        $result = $service->canonicalize([
            'birthday' => '1996-08-18',
            'birth_time' => '10:30',
            'birth_place' => '河南南阳',
            'gender' => 'male',
            'user_id' => 1001,
            'platform' => 'android',
        ]);

        $this->assertArrayHasKey('ziwei', $result);
        $ziwei = (array) ($result['ziwei'] ?? []);
        $this->assertSame('ziwei_canonical_server', (string) ($ziwei['engine'] ?? ''));
        $this->assertNotEmpty($ziwei['life_palace'] ?? null);
        $this->assertNotEmpty($ziwei['body_palace'] ?? null);
        $this->assertIsArray($ziwei['palaces'] ?? null);
        $this->assertNotEmpty($ziwei['palaces'] ?? []);
        $this->assertArrayHasKey('summary', $ziwei);
        $this->assertArrayHasKey('major_themes', $ziwei);
    }
}
