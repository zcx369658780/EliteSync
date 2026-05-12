<?php

return [
    'android' => [
        'latest_version_name' => env('ANDROID_LATEST_VERSION_NAME', '0.05.10'),
        'latest_version_code' => (int) env('ANDROID_LATEST_VERSION_CODE', 51000),
        'min_supported_version_name' => env('ANDROID_MIN_SUPPORTED_VERSION_NAME', '0.01.01'),
        'download_url' => env('ANDROID_DOWNLOAD_URL', 'http://101.133.161.203/downloads/elitesync-0.05.10.apk'),
        'changelog' => env('ANDROID_CHANGELOG', '完成 5.6-5.10 玄学能力二次产品化阶段收口：Match 关系解释层、Profile 个人表达建议层、Chat 低压开场建议层与 Settings 解释与建议控制入口已纳入当前包体；解释和建议继续保持 display-only / no-write / no-auto-send，不写资料、不改变星盘或匹配算法、不自动发送消息；管理员账号登录后仍可在设置中看到运营管理入口；同步版本检查、下载地址与发布元数据到 0.05.10 / 51000。'),
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
