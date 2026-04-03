<?php

namespace Tests\Unit;

use App\Services\BaiduWebApiSigner;
use PHPUnit\Framework\TestCase;

class BaiduWebApiSignerTest extends TestCase
{
    public function test_sign_matches_baidu_official_example(): void
    {
        $signer = new BaiduWebApiSigner();
        $queryString = http_build_query([
            'address' => '百度大厦',
            'output' => 'json',
            'ak' => 'yourak',
        ]);

        $sn = $signer->sign('/geocoder/v2/', $queryString, 'yoursk');

        $this->assertSame('7de5a22212ffaa9e326444c75a58f9a0', $sn);
    }

    public function test_build_signed_url_contains_sn_and_ak(): void
    {
        $signer = new BaiduWebApiSigner();
        $url = $signer->buildSignedUrl('/place/v2/suggestion', [
            'query' => '武汉大学',
            'region' => '武汉市',
            'city_limit' => false,
            'output' => 'json',
        ], 'yourak', 'yoursk');

        $this->assertStringContainsString('ak=yourak', $url);
        $this->assertStringContainsString('sn=', $url);
    }
}
