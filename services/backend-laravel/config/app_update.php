<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.02.08'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 208),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.02.08.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 2.8 信任安全与运营后台补完版：新增聊天举报/拉黑、账号状态展示、运营看板、举报处理、认证审核和用户列表；前台安全出口与后台治理链路已打通，并与服务端版本检查同步到 0.02.08。'),
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
