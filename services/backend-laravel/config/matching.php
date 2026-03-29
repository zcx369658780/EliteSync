<?php

return [
    // Runtime-selectable natal engine adapter: default|standard
    'astro_engine_adapter' => env('MATCHING_ASTRO_ENGINE_ADAPTER', 'default'),
    // Runtime-selectable western compatibility engine: default|standard
    'western_engine' => env('MATCHING_WESTERN_ENGINE', 'default'),

    'contract' => [
        // Payload contract version for match_reasons.
        'version' => 'v1',
    ],

    'algo_versions' => [
        // Module algorithm version markers for telemetry/debug.
        'personality' => 'p1',
        'mbti' => 'p1',
        'bazi' => 'p2',
        'zodiac' => 'p2',
        'constellation' => 'p1',
        'natal_chart' => 'p2',
        'pair_chart' => 'p2',
    ],

    'core_weights' => [
        // Algo 2.2 transition:
        // MBTI is downgraded from core sorter to lightweight factor.
        'personality' => (float) env('MATCH_WEIGHT_PERSONALITY', 0.58),
        'mbti' => (float) env('MATCH_WEIGHT_MBTI', 0.07),
        'astro' => (float) env('MATCH_WEIGHT_ASTRO', 0.35),
    ],

    'score_guards' => [
        // Prevent over-dominance by one module.
        'personality_low_threshold' => 45,
        'personality_low_cap' => 72,
        'personality_high_threshold' => 75,
        'personality_high_floor' => 40,
    ],

    'hard_filters' => [
        // V1 product constraints
        'same_city_only' => true,
        'opposite_gender_only' => true,
        'reject_casual_vs_marriage' => true,
        'exclude_recent_pair_days' => 14,
    ],

    'soft_penalties' => [
        'relationship_goal_partial_mismatch' => 0.70,
        'lifestyle_mismatch' => 0.85,
        'communication_mismatch' => 0.88,
        'interest_overlap_low' => 0.92,
    ],

    'fairness' => [
        // Based on candidate recent exposure count (7d), apply multiplier.
        'buckets' => [
            ['min' => 40, 'multiplier' => 0.70],
            ['min' => 20, 'multiplier' => 0.82],
            ['min' => 8, 'multiplier' => 1.00],
            ['min' => 3, 'multiplier' => 1.05],
            ['min' => 0, 'multiplier' => 1.10],
        ],
    ],

    'debug' => [
        // false: synthetic users are excluded from matching.
        // true: synthetic users can be included in matching (for algorithm debug/load test).
        'include_synthetic_users_default' => filter_var(
            env('MATCHING_DEBUG_INCLUDE_SYNTHETIC_USERS', true),
            FILTER_VALIDATE_BOOL
        ),
        // Production safety guard for synthetic-data commands.
        'allow_synthetic_commands_in_production' => filter_var(
            env('MATCHING_ALLOW_SYNTHETIC_COMMANDS_IN_PRODUCTION', false),
            FILTER_VALIDATE_BOOL
        ),
    ],

    // Calibration injector guardrails (dev/staging only by default).
    'calibration_injector' => [
        'enabled' => filter_var(
            env('MATCHING_CALIBRATION_INJECTOR_ENABLED', false),
            FILTER_VALIDATE_BOOL
        ),
        'allow_in_production' => filter_var(
            env('MATCHING_CALIBRATION_INJECTOR_ALLOW_IN_PRODUCTION', false),
            FILTER_VALIDATE_BOOL
        ),
        // Content marker prefix for injected chat rows.
        'message_marker_prefix' => env('MATCHING_CALIBRATION_MESSAGE_MARKER_PREFIX', '[[calibration_injector]]'),
        // By default, metrics/export exclude injected calibration signals.
        'include_in_metrics_default' => filter_var(
            env('MATCHING_CALIBRATION_INCLUDE_IN_METRICS', false),
            FILTER_VALIDATE_BOOL
        ),
    ],

    // Additional user-signal based adjustments for Beta tuning.
    'signal_adjustments' => [
        // Same city gets a small boost.
        'same_city_multiplier' => 1.12,
        // Age gap (years) bucket multipliers.
        // Applied as first bucket where age_gap <= max.
        'age_gap' => [
            ['max' => 3, 'multiplier' => 1.04],
            ['max' => 6, 'multiplier' => 1.00],
            ['max' => 9, 'multiplier' => 0.93],
            ['max' => 99, 'multiplier' => 0.85],
        ],
        // MBTI letter match gives a tiny boost.
        'mbti' => [
            // MBTI is now a core module; disable legacy per-letter multiplier to avoid double counting.
            'enabled' => false,
            'per_letter_bonus' => 0.015,
            'max_multiplier' => 1.06,
        ],
    ],
];
