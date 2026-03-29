<?php

return [
    // canonical source strategy:
    // - lunar_php: server-side canonical via lunar-php (phase-1 default)
    // - legacy_client: trust client-computed astro payload as temporary bridge
    // - server_engine: alias for server-side canonical engines
    'engine' => env('ASTRO_CANONICAL_ENGINE', 'lunar_php'),

    // meta labels written into notes for traceability.
    'labels' => [
        'legacy_client' => 'legacy_estimate',
        'server_engine' => 'canonical_server',
        'lunar_php' => 'canonical_server',
    ],
];
