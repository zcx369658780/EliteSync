<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.05.05'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 50500),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.05.05.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 5.5 真实小样本反馈吸收版收口：状态发布 / 状态作者页 Map/List 响应兼容、个人页浮动发布入口遮挡、紫微预览裁切、RTC 接收端 watcher 与终态来电页操作状态已修复，并补齐 Claude Appium 测试员流程、双端 RTC、阿里云 30 秒 invite timeout 与写入式复测证据；同步版本检查、下载地址与发布元数据到 0.05.05 / 50500。'),
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
