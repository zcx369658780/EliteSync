<?php

namespace App\Services;

interface BaziEngine
{
    /**
     * Canonicalize astro payload.
     *
     * @param array<string,mixed> $payload
     * @return array{
     *   sun_sign:string,
     *   moon_sign:?string,
     *   asc_sign:?string,
     *   bazi:?string,
     *   true_solar_time:?string,
     *   da_yun:array<int,mixed>,
     *   liu_nian:array<int,mixed>,
     *   wu_xing:array<string,mixed>,
     *   notes:array<int,string>,
     *   accuracy:string,
     *   confidence:float
     * }
     */
    public function canonicalize(array $payload): array;
}

