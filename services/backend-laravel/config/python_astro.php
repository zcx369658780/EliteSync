<?php

return [
    'render_url' => env('PY_ASTRO_RENDER_URL', 'http://127.0.0.1:8002/api/v1/profile/astro/render'),
    'timeout_seconds' => (int) env('PY_ASTRO_RENDER_TIMEOUT', 20),
];
