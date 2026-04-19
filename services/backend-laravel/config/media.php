<?php

return [
    'disk' => env(
        'MEDIA_STORAGE_DISK',
        env('OSS_BUCKET') ? 'oss' : (env('AWS_BUCKET') ? 's3' : 'public')
    ),
    'queue_name' => env('MEDIA_QUEUE', 'media'),
    'max_upload_bytes' => (int) env('MEDIA_MAX_UPLOAD_BYTES', 25 * 1024 * 1024),
    'cache_ttl_seconds' => (int) env('MEDIA_CACHE_TTL_SECONDS', 300),
    'allowed_mime_prefixes' => array_filter(array_map('trim', explode(',', env('MEDIA_ALLOWED_MIME_PREFIXES', 'image/,video/')))),
    'public_base_path' => trim((string) env('MEDIA_PUBLIC_BASE_PATH', 'chat-media'), '/'),
];
