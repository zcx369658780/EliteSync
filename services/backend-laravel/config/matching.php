<?php

return [
    'hard_filters' => [
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
];

