<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.04.09'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 40900),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.04.09.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 4.9 测试前治理、限流、监控与发布链强化版收口：通知中心工程 slug 降噪、RTC / LiveKit / Heartbeat 可观测性、媒体可观测性、数据库正式演练与 UI baseline regression 门禁已纳入主链，并同步版本检查、下载地址与发布元数据到 0.04.09 / 40900。'),
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
