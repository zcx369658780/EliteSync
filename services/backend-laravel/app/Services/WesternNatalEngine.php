<?php

namespace App\Services;

interface WesternNatalEngine
{
    /**
     * @param array<string,mixed> $payload
     * @return array{
     *   sun_sign:string,
     *   moon_sign:?string,
     *   asc_sign:?string,
     *   engine:string,
     *   precision:string,
     *   confidence:float,
     *   degraded:bool,
     *   degrade_reason:string
     * }
     */
    public function compute(array $payload): array;
}

