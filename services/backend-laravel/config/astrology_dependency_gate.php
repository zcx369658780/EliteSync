<?php

return [
    // When false, dependencies marked blocked_default cannot be enabled at runtime.
    'research_mode' => filter_var(env('ASTRO_RESEARCH_MODE', false), FILTER_VALIDATE_BOOL),

    'dependencies' => [
        'swisseph' => [
            'blocked_default' => true,
            'reason' => 'Swiss Ephemeris licensing requires commercial/legal confirmation for closed-source production.',
        ],
        'pyswisseph' => [
            'blocked_default' => true,
            'reason' => 'AGPL-3.0 dependency cannot be default-enabled for closed-source production.',
        ],
        'kerykeion' => [
            'blocked_default' => true,
            'reason' => 'AGPL-3.0 dependency cannot be default-enabled for closed-source production.',
        ],
        'flatlib' => [
            'blocked_default' => false,
            'reason' => 'Library is MIT, but dependent Swiss license chain must be reviewed when used with Swiss runtime.',
        ],
    ],
];

