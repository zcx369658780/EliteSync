<?php

return [
    'android_ak' => env('BAIDU_ANDROID_AK', env('BAIDU_MAP_AK', '')),
    'web_ak' => env('BAIDU_WEB_AK', ''),
    'web_sk' => env('BAIDU_WEB_SK', ''),
    'ak' => env('BAIDU_WEB_AK', env('BAIDU_MAP_AK', '')),
];
