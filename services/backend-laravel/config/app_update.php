<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.02.06'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 206),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.02.06.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 2.6 到 2.6.3a 的玄学可视化收口：重构总览、八字、星盘、紫微页面；补齐盘面设置、本地展示偏好与星盘 SVG 专业化；同步清理紫微/八字视觉噪声并保持服务端 canonical 真值不变。'),
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
