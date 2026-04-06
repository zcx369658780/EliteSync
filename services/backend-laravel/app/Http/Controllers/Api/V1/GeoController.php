<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\BaiduWebApiSigner;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class GeoController extends Controller
{
    public function places(Request $request): JsonResponse
    {
        $data = $request->validate([
            'query' => ['required', 'string', 'max:100'],
            'region' => ['nullable', 'string', 'max:100'],
        ]);

        $ak = (string) config('baidu.web_ak');
        $sk = (string) config('baidu.web_sk');
        if ($ak === '' || $sk === '') {
            return response()->json([
                'message' => 'BAIDU_WEB_AK / BAIDU_WEB_SK is not configured on server',
                'places' => [],
            ], 500);
        }

        $query = trim($data['query']);
        $region = trim((string) ($data['region'] ?? '全国'));
        $signer = app(BaiduWebApiSigner::class);

        try {
            $places = $this->fetchSuggestions($query, $region, $ak, $sk, $signer);
            if ($places !== []) {
                return response()->json(['places' => $places]);
            }

            $places = $this->fetchSearchResults($query, $region, $ak, $sk, $signer);
            if ($places !== []) {
                return response()->json(['places' => $places]);
            }

            $fallback = $this->fetchGeocodingFallback($query, $region, $ak, $sk, $signer);
            return response()->json(['places' => $fallback]);
        } catch (\RuntimeException $e) {
            return response()->json([
                'message' => $e->getMessage(),
                'places' => [],
            ], 503);
        }
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function fetchSuggestions(string $query, string $region, string $ak, string $sk, BaiduWebApiSigner $signer): array
    {
        $regions = array_values(array_unique(array_filter([
            $region,
            '中国',
            '全国',
            '北京',
            '上海',
        ])));

        $merged = [];
        foreach ($regions as $candidateRegion) {
            $resp = Http::timeout(8)->get($signer->buildSignedUrl('/place/v2/suggestion', [
                'query' => $query,
                'region' => $candidateRegion,
                'city_limit' => false,
                'output' => 'json',
            ], $ak, $sk));
            if (!$resp->successful()) {
                continue;
            }
            $json = $resp->json();
            $this->assertBaiduResponse($json, 'suggestion');
            if (!is_array($json) || (int) ($json['status'] ?? -1) !== 0) {
                continue;
            }
            $items = $json['result'] ?? [];
            if (!is_array($items)) {
                continue;
            }
            foreach ($items as $item) {
                if (!is_array($item)) {
                    continue;
                }
                $loc = $item['location'] ?? null;
                if (!is_array($loc)) {
                    continue;
                }
                $lat = $loc['lat'] ?? null;
                $lng = $loc['lng'] ?? null;
                if (!is_numeric($lat) || !is_numeric($lng)) {
                    continue;
                }
                $key = trim((string) ($item['name'] ?? '')) . '|' . $lat . '|' . $lng;
                if (isset($merged[$key])) {
                    continue;
                }
                $merged[$key] = [
                    'label' => trim((string) ($item['name'] ?? '')) ?: $query,
                    'address' => (string) ($item['address'] ?? ''),
                    'city' => (string) ($item['city'] ?? ''),
                    'district' => (string) ($item['district'] ?? ''),
                    'lat' => (float) $lat,
                    'lng' => (float) $lng,
                    '_score' => $this->rankPlace(
                        query: $query,
                        region: $region,
                        name: trim((string) ($item['name'] ?? '')),
                        city: (string) ($item['city'] ?? ''),
                        district: (string) ($item['district'] ?? ''),
                        address: (string) ($item['address'] ?? '')
                    ),
                ];
                if (count($merged) >= 10) {
                    return $this->sortPlaces(array_values($merged));
                }
            }
        }

        return $this->sortPlaces(array_values($merged));
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function fetchGeocodingFallback(string $query, string $region, string $ak, string $sk, BaiduWebApiSigner $signer): array
    {
        $regions = array_values(array_unique(array_filter([
            $region,
            '全国',
            '中国',
            '北京',
        ])));

        foreach ($regions as $candidateRegion) {
            $resp = Http::timeout(8)->get($signer->buildSignedUrl('/geocoding/v3', [
                'address' => $query,
                'city' => $candidateRegion,
                'output' => 'json',
            ], $ak, $sk));
            if (!$resp->successful()) {
                continue;
            }
            $json = $resp->json();
            $this->assertBaiduResponse($json, 'search');
            if (!is_array($json) || (int) ($json['status'] ?? -1) !== 0) {
                continue;
            }
            $result = $json['result'] ?? null;
            if (!is_array($result)) {
                continue;
            }
            $location = $result['location'] ?? null;
            if (!is_array($location)) {
                continue;
            }
            $lat = $location['lat'] ?? null;
            $lng = $location['lng'] ?? null;
            if (!is_numeric($lat) || !is_numeric($lng)) {
                continue;
            }

            return [[
                'label' => $query,
                'address' => $query,
                'city' => $candidateRegion === '全国' ? '' : $candidateRegion,
                'district' => '',
                'lat' => (float) $lat,
                'lng' => (float) $lng,
                '_score' => 1,
            ]];
        }

        return [];
    }

    /**
     * @return array<int, array<string, mixed>>
     */
    private function fetchSearchResults(string $query, string $region, string $ak, string $sk, BaiduWebApiSigner $signer): array
    {
        $regions = array_values(array_unique(array_filter([
            $region,
            '中国',
            '全国',
            '北京',
            '上海',
        ])));

        $merged = [];
        foreach ($regions as $candidateRegion) {
            $resp = Http::timeout(8)->get($signer->buildSignedUrl('/place/v2/search', [
                'query' => $query,
                'region' => $candidateRegion,
                'city_limit' => false,
                'output' => 'json',
            ], $ak, $sk));
            if (!$resp->successful()) {
                continue;
            }
            $json = $resp->json();
            $this->assertBaiduResponse($json, 'geocoding');
            if (!is_array($json) || (int) ($json['status'] ?? -1) !== 0) {
                continue;
            }
            $items = $json['results'] ?? [];
            if (!is_array($items)) {
                continue;
            }
            foreach ($items as $item) {
                if (!is_array($item)) {
                    continue;
                }
                $loc = $item['location'] ?? null;
                if (!is_array($loc)) {
                    continue;
                }
                $lat = $loc['lat'] ?? null;
                $lng = $loc['lng'] ?? null;
                if (!is_numeric($lat) || !is_numeric($lng)) {
                    continue;
                }
                $key = trim((string) ($item['name'] ?? '')) . '|' . $lat . '|' . $lng;
                if (isset($merged[$key])) {
                    continue;
                }
                $merged[$key] = [
                    'label' => trim((string) ($item['name'] ?? '')) ?: $query,
                    'address' => (string) ($item['address'] ?? ''),
                    'city' => (string) ($item['city'] ?? ''),
                    'district' => (string) ($item['area'] ?? ''),
                    'lat' => (float) $lat,
                    'lng' => (float) $lng,
                    '_score' => $this->rankPlace(
                        query: $query,
                        region: $region,
                        name: trim((string) ($item['name'] ?? '')),
                        city: (string) ($item['city'] ?? ''),
                        district: (string) ($item['area'] ?? ''),
                        address: (string) ($item['address'] ?? '')
                    ),
                ];
                if (count($merged) >= 10) {
                    return $this->sortPlaces(array_values($merged));
                }
            }
        }

        return $this->sortPlaces(array_values($merged));
    }

    /**
     * @param array<string,mixed>|null $json
     */
    private function assertBaiduResponse(?array $json, string $endpoint): void
    {
        if (!is_array($json)) {
            return;
        }
        $status = (int) ($json['status'] ?? -1);
        if ($status === 240) {
            $message = match ($endpoint) {
                'suggestion' => '百度地点服务未启用或已被禁用，请在百度控制台开启 Place/Geocoding 服务',
                'search' => '百度地点检索服务未启用或已被禁用，请在百度控制台开启 Place/Geocoding 服务',
                'geocoding' => '百度地理编码服务未启用或已被禁用，请在百度控制台开启 Place/Geocoding 服务',
                default => '百度地点服务未启用或已被禁用，请在百度控制台开启相关服务',
            };
            throw new \RuntimeException($message);
        }
    }

    /**
     * @param array<int, array<string, mixed>> $places
     * @return array<int, array<string, mixed>>
     */
    private function sortPlaces(array $places): array
    {
        usort($places, function (array $a, array $b): int {
            return (($b['_score'] ?? 0) <=> ($a['_score'] ?? 0))
                ?: strcmp((string) ($a['label'] ?? ''), (string) ($b['label'] ?? ''));
        });

        return array_map(function (array $item): array {
            unset($item['_score']);
            return $item;
        }, $places);
    }

    private function rankPlace(string $query, string $region, string $name, string $city, string $district, string $address): int
    {
        $score = 0;
        $queryNorm = $this->normalizeText($query);
        $nameNorm = $this->normalizeText($name);
        $cityNorm = $this->normalizeText($city);
        $districtNorm = $this->normalizeText($district);
        $addressNorm = $this->normalizeText($address);
        $regionNorm = $this->normalizeText($region);

        if ($nameNorm === $queryNorm) {
            $score += 500;
        } elseif (str_contains($nameNorm, $queryNorm) || str_contains($queryNorm, $nameNorm)) {
            $score += 350;
        }

        if ($cityNorm !== '' && ($regionNorm !== '' && $cityNorm === $regionNorm)) {
            $score += 120;
        }

        if ($districtNorm !== '' && str_contains($queryNorm, $districtNorm)) {
            $score += 80;
        }

        if ($addressNorm !== '' && str_contains($addressNorm, $queryNorm)) {
            $score += 60;
        }

        if (str_contains($queryNorm, '大学') && str_contains($nameNorm, '大学')) {
            $score += 40;
        }

        return $score;
    }

    private function normalizeText(string $value): string
    {
        $value = trim(mb_strtolower($value));
        $value = preg_replace('/\s+/u', '', $value) ?? $value;
        $value = preg_replace('/(省|市|自治区|自治州|地区|盟|区|县|学院|大学)$/u', '', $value) ?? $value;
        return $value;
    }
}
