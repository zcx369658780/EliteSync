<?php

namespace App\Services;

interface WesternCompatibilityEngine
{
    /**
     * @return array{
     *   sun_a:string,sun_b:string,moon_a:string,moon_b:string,asc_a:string,asc_b:string,
     *   emotion_sync:float,expression_sync:float,direction_sync:float,
     *   has_moon:bool,has_asc:bool,completeness_level:int,source:string
     * }
     */
    public function natalMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array;

    /**
     * @return array{
     *   sun_a:string,sun_b:string,moon_a:string,moon_b:string,asc_a:string,asc_b:string,
     *   sun_moon_ab:float,sun_moon_ba:float,sun_moon_avg:float,asc_score:float,emotion_score:float,
     *   has_sun:bool,has_moon:bool,has_asc:bool,component_count:int,full_data:bool,source:string
     * }
     */
    public function pairMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array;
}

