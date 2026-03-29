<?php

return [
    // selectable: legacy_input | swisseph | pyswisseph | kerykeion
    // high-risk engines are gated by AstrologyDependencyGateService.
    'engine' => env('WESTERN_NATAL_ENGINE', 'legacy_input'),

    'labels' => [
        'legacy_input' => 'legacy_estimate',
        'swisseph' => 'high_precision',
        'pyswisseph' => 'high_precision',
        'kerykeion' => 'high_precision',
    ],
];

