<?php

namespace App\Services;

class StandardWesternCompatibilityEngine implements WesternCompatibilityEngine
{
    public function natalMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        /** @var DefaultWesternCompatibilityEngine $fallback */
        $fallback = app(DefaultWesternCompatibilityEngine::class);
        $m = $fallback->natalMetrics($chartA, $chartB, $sunA, $sunB);
        $m['source'] = 'standard_stub_v1';
        return $m;
    }

    public function pairMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        /** @var DefaultWesternCompatibilityEngine $fallback */
        $fallback = app(DefaultWesternCompatibilityEngine::class);
        $m = $fallback->pairMetrics($chartA, $chartB, $sunA, $sunB);
        $m['source'] = 'standard_stub_v1';
        return $m;
    }
}

