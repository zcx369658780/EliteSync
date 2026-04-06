<?php

return [
    // Unified confidence downgrade policy for explanation layer.
    // This file is introduced in algo-2.2 migration as centralized policy.
    'astro' => [
        'no_birth_time' => [
            'affected' => ['natal_chart', 'pair_chart'],
            'confidence_cap' => 0.70,
            'precision' => 'partial_time',
        ],
        'no_birth_location' => [
            'affected' => ['natal_chart', 'pair_chart'],
            'confidence_cap' => 0.65,
            'precision' => 'no_location',
        ],
        'date_only' => [
            'affected' => ['natal_chart', 'pair_chart', 'bazi'],
            'confidence_cap' => 0.55,
            'precision' => 'date_only',
        ],
        'zodiac_gregorian_fallback' => [
            'affected' => ['zodiac'],
            'confidence_cap' => 0.45,
            'precision' => 'legacy_fallback',
        ],
        'bazi_incomplete' => [
            'affected' => ['bazi'],
            'confidence_cap' => 0.60,
            'precision' => 'partial_bazi',
        ],
    ],
    // Explanation tone/strength normalization policy.
    'narrative' => [
        'low_confidence_threshold' => 0.55,
        'medium_confidence_threshold' => 0.70,
        'low_confidence_suffix' => '（当前证据偏弱，建议仅作参考）',
        'degraded_suffix' => '（存在降级估算，建议补全出生信息后再判断）',
    ],
];
