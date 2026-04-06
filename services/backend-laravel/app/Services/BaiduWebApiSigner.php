<?php

namespace App\Services;

class BaiduWebApiSigner
{
    /**
     * @param array<string, scalar|null> $queryParams
     */
    public function buildSignedUrl(string $path, array $queryParams, string $ak, string $sk): string
    {
        $params = $queryParams;
        $params['ak'] = $ak;
        $queryString = http_build_query($params);
        $sn = $this->sign($path, $queryString, $sk);

        return 'https://api.map.baidu.com'.$path.'?'.$queryString.'&sn='.$sn;
    }

    public function sign(string $path, string $queryString, string $sk): string
    {
        return md5(urlencode($path.'?'.$queryString.$sk));
    }
}
