<?php

return [
    // Set true in cloud production after HTTPS/WSS is configured.
    'enforce_https' => (bool) env('SECURITY_ENFORCE_HTTPS', false),
];
