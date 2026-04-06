<?php

namespace Tests\Unit;

use App\Services\BirthLocationSolarTimeService;
use Tests\TestCase;

class BirthLocationSolarTimeServiceTest extends TestCase
{
    public function test_resolve_changes_true_solar_time_for_different_birth_locations(): void
    {
        $service = app(BirthLocationSolarTimeService::class);

        $beijing = $service->resolve([
            'birthday' => '1996-08-18',
            'birth_time' => '10:30',
            'birth_place' => '北京',
            'birth_lat' => 39.9042,
            'birth_lng' => 116.4074,
        ]);

        $urumqi = $service->resolve([
            'birthday' => '1996-08-18',
            'birth_time' => '10:30',
            'birth_place' => '乌鲁木齐',
            'birth_lat' => 43.8256,
            'birth_lng' => 87.6168,
        ]);

        $this->assertSame('longitude_based', (string) ($beijing['location_source'] ?? ''));
        $this->assertSame('longitude_based', (string) ($urumqi['location_source'] ?? ''));
        $this->assertNotSame((string) ($beijing['true_solar_time'] ?? ''), (string) ($urumqi['true_solar_time'] ?? ''));
        $this->assertNotSame((int) ($beijing['location_shift_minutes'] ?? 0), (int) ($urumqi['location_shift_minutes'] ?? 0));
        $this->assertNotEmpty((string) ($beijing['position_signature'] ?? ''));
        $this->assertNotEmpty((string) ($urumqi['position_signature'] ?? ''));
    }
}
