<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.04.04'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 40400),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.04.04.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 4.3 动态流基础版、4.4 视频消息版与 4.4S 媒体链稳定性修正版的收口：动态发布 / 读取 / 点赞 / 删除 / 举报 / 拉黑 / 作者页联动、视频消息发送 / 预览 / 回读，以及图片 / 视频内容端点与 public_url 规范化修复已纳入主链，并同步版本检查、下载地址与发布元数据到 0.04.04 / 40400。'),
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
