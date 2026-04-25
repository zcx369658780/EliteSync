<?php

return [
    'enabled' => filter_var(env('LIVEKIT_ENABLED', 'false'), FILTER_VALIDATE_BOOL),
    'url' => env('LIVEKIT_URL', ''),
    'api_key' => env('LIVEKIT_API_KEY', ''),
    'api_secret' => env('LIVEKIT_API_SECRET', ''),
    'ttl_seconds' => (int) env('LIVEKIT_TOKEN_TTL_SECONDS', 600),
];

