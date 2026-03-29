<?php

namespace App\Services;

class StandardAstroEngineAdapter implements AstroEngineAdapter
{
    public function extractSigns(mixed $chart, string $sunSign): array
    {
        // Placeholder adapter for future standard ephemeris integration.
        // Current behavior keeps payload contract stable while allowing runtime switch.
        $moon = is_array($chart) ? (string) ($chart['moon_sign'] ?? '') : '';
        $asc = is_array($chart) ? (string) ($chart['asc_sign'] ?? '') : '';

        return [
            'sun_sign' => trim($sunSign),
            'moon_sign' => trim($moon),
            'asc_sign' => trim($asc),
            'source' => 'standard_stub_v1',
        ];
    }
}

