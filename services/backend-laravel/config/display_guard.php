<?php

return [
    // Guard rules used to decide whether UI can show strong/confident badges.
    'confidence' => [
        'high_threshold' => 0.82,
        'strong_evidence_threshold' => 0.76,
        'precise_wording_threshold' => 0.72,
    ],

    // Only canonical modules with adequate precision can claim high confidence.
    'engine' => [
        'allow_high_confidence_modes' => ['canonical'],
        'deny_high_confidence_modes' => ['legacy', 'fallback', 'hybrid'],
    ],

    'precision' => [
        'allow_high_confidence_levels' => ['high', 'medium'],
        'deny_high_confidence_levels' => ['low', 'estimated'],
    ],

    'data_quality' => [
        'allow_high_confidence_levels' => ['exact_time+location', 'exact_time_only'],
        'deny_high_confidence_levels' => ['date_only', 'partial_unknown'],
    ],

    // Minimum evidence count to issue "strong evidence" badge.
    'evidence' => [
        'core_min_count' => 2,
    ],
];

