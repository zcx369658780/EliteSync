<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.05.04'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 50400),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.05.04.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 5.0-5.4 高价值主链覆盖与测试运营准备阶段收口：Discover / Chat / Me / Settings 的产品化补强、关系推进、个人经营表达层、功能覆盖收尾，以及 5.4 只读运营准备入口、观测入口、Smoke / Regression Matrix 和 Runbook Library 已纳入主链，并同步版本检查、下载地址与发布元数据到 0.05.04 / 50400。'),
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
