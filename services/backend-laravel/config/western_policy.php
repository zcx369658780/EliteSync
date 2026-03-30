<?php

return [
    // legacy_display: keep current non-canonical/partial western output for display only.
    // hybrid_candidate: allow controlled hybrid (shadow compare + whitelist).
    // canonical_authorized: western canonical is commercially authorized and production-ready.
    'mode' => env('WESTERN_POLICY_MODE', 'legacy_display'),

    'allow_precise_wording_modes' => [
        'canonical_authorized',
    ],

    'allow_high_confidence_modes' => [
        'canonical_authorized',
    ],
];

