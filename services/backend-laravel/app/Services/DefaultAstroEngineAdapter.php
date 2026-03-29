<?php

namespace App\Services;

class DefaultAstroEngineAdapter implements AstroEngineAdapter
{
    public function extractSigns(mixed $chart, string $sunSign): array
    {
        $moon = is_array($chart) ? (string) ($chart['moon_sign'] ?? '') : '';
        $asc = is_array($chart) ? (string) ($chart['asc_sign'] ?? '') : '';

        return [
            'sun_sign' => trim($sunSign),
            'moon_sign' => trim($moon),
            'asc_sign' => trim($asc),
            'source' => 'default_v1',
        ];
    }
}

