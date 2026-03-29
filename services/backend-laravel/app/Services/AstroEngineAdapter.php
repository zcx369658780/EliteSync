<?php

namespace App\Services;

interface AstroEngineAdapter
{
    /**
     * @return array{
     *   sun_sign:string,
     *   moon_sign:string,
     *   asc_sign:string,
     *   source:string
     * }
     */
    public function extractSigns(mixed $chart, string $sunSign): array;
}

