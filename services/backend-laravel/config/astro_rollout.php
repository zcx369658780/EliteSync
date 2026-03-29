<?php

return [
    // Bazi canonical rollout controls (service-side truth source).
    'bazi' => [
        'enabled' => env('ASTRO_BAZI_CANONICAL_ENABLED', true),
        // When enabled=false, only whitelisted users can use canonical engine.
        'whitelist_user_ids' => array_values(array_filter(array_map(
            fn ($v) => (int) trim($v),
            explode(',', (string) env('ASTRO_BAZI_CANONICAL_WHITELIST', ''))
        ), fn ($v) => $v > 0)),
        // Optional platform override: legacy|canonical|null
        'platform_overrides' => [
            'android' => env('ASTRO_BAZI_CANONICAL_ANDROID', ''),
            'ios' => env('ASTRO_BAZI_CANONICAL_IOS', ''),
            'web' => env('ASTRO_BAZI_CANONICAL_WEB', ''),
        ],
        // Optional profile version lower-bound for canonical path.
        'min_profile_version' => (int) env('ASTRO_BAZI_MIN_PROFILE_VERSION', 0),
    ],

    // Western natal canonical rollout controls.
    'western' => [
        'enabled' => env('ASTRO_WESTERN_CANONICAL_ENABLED', false),
        'whitelist_user_ids' => array_values(array_filter(array_map(
            fn ($v) => (int) trim($v),
            explode(',', (string) env('ASTRO_WESTERN_CANONICAL_WHITELIST', ''))
        ), fn ($v) => $v > 0)),
        'platform_overrides' => [
            'android' => env('ASTRO_WESTERN_CANONICAL_ANDROID', ''),
            'ios' => env('ASTRO_WESTERN_CANONICAL_IOS', ''),
            'web' => env('ASTRO_WESTERN_CANONICAL_WEB', ''),
        ],
        'min_profile_version' => (int) env('ASTRO_WESTERN_MIN_PROFILE_VERSION', 0),
    ],
];

