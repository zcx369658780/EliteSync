<?php

namespace App\Services;

use Carbon\CarbonImmutable;

class ChineseZodiacService
{
    public function __construct(private readonly BaziDerivedZodiacService $baziDerivedZodiacService)
    {
    }

    /**
     * Order starts at Rat(鼠) for year where (year - 4) % 12 = 0.
     * V1 uses Gregorian birth year for deterministic backfill and low complexity.
     */
    private const ANIMALS = ['鼠', '牛', '虎', '兔', '龙', '蛇', '马', '羊', '猴', '鸡', '狗', '猪'];

    public function fromBirthdayString(?string $birthday): ?string
    {
        if (!$birthday) {
            return null;
        }

        try {
            $date = CarbonImmutable::parse($birthday);
        } catch (\Throwable) {
            return null;
        }

        return $this->fromYear((int) $date->year);
    }

    /**
     * Preferred chain for V2:
     * 1) derive from bazi year pillar
     * 2) fallback to birthday-derived zodiac (legacy)
     */
    public function fromPreferredSources(?string $bazi, ?string $birthday): ?string
    {
        $fromBazi = $this->baziDerivedZodiacService->fromBaziString($bazi);
        if ($fromBazi !== null && $fromBazi !== '') {
            return $fromBazi;
        }

        return $this->fromBirthdayString($birthday);
    }

    public function fromYear(int $year): string
    {
        $idx = ($year - 4) % 12;
        if ($idx < 0) {
            $idx += 12;
        }

        return self::ANIMALS[$idx];
    }
}
