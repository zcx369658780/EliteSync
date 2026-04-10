<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.03.02a'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 30201),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.03.02a.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 3.2a 版本收口：星盘主视觉切换为 APP 端本地绘制，盘面元素开关细分到星体 / 虚点 / 相位 / 盘心，Android 宿主 bootstrap 已补齐 API / WS 基线注入，并同步版本检查、下载地址与发布元数据到 0.03.02a / 30201。'),
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
