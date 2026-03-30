<?php

return [
    // western_lite: keep current western output as a lightweight display/analysis module only.
    // hybrid_candidate: allow controlled hybrid (shadow compare + whitelist).
    // licensed_canonical: western canonical is commercially authorized and production-ready.
    'mode' => env('WESTERN_POLICY_MODE', 'western_lite'),

    'allow_precise_wording_modes' => [
        'licensed_canonical',
    ],

    'allow_high_confidence_modes' => [
        'licensed_canonical',
    ],
];
