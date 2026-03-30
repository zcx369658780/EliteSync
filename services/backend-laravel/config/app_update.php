<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.02.03'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 203),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'https://slowdate.top/downloads/elitesync-0.02.03.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '匹配详情兼容新算法字段结构并修复崩溃；完成算法 2.2 服务端真源与解释展示联动；文档体系精简并补齐许可证审计。'),
        'sha256' => env('ANDROID_APK_SHA256', ''),
        'force_update' => (bool) env('ANDROID_FORCE_UPDATE', false),
    ],
    'ios' => [
        'latest_version_name' => env('IOS_LATEST_VERSION_NAME', '0.01.01'),
        'latest_version_code' => (int) env('IOS_LATEST_VERSION_CODE', 101),
        'min_supported_version_name' => env('IOS_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('IOS_DOWNLOAD_URL', ''),
        'changelog' => env('IOS_CHANGELOG', ''),
        'sha256' => env('IOS_APP_SHA256', ''),
        'force_update' => (bool) env('IOS_FORCE_UPDATE', false),
    ],
];
