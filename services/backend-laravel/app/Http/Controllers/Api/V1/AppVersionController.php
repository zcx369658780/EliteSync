<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppReleaseVersion;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Throwable;

class AppVersionController extends Controller
{
    public function check(Request $request): JsonResponse
    {
        $data = $request->validate([
            'platform' => ['required', 'in:android,ios'],
            'channel' => ['nullable', 'string', 'max:32'],
            'version_name' => ['required', 'string', 'max:32'],
            'version_code' => ['nullable', 'integer', 'min:1'],
        ]);

        $platform = $data['platform'];
        $channel = (string) ($data['channel'] ?? 'stable');
        $clientVersion = (string) $data['version_name'];
        $clientCode = (int) ($data['version_code'] ?? 0);

        $release = null;
        try {
            $release = AppReleaseVersion::query()
                ->where('platform', $platform)
                ->where('channel', $channel)
                ->where('is_active', true)
                ->orderByDesc('version_code')
                ->orderByDesc('id')
                ->first();
        } catch (Throwable) {
            // Fallback to config-only mode when DB is temporarily unavailable.
            $release = null;
        }

        $default = config("app_update.$platform", []);
        $latestVersionName = (string) ($release->version_name ?? ($default['latest_version_name'] ?? $clientVersion));
        $latestVersionCode = (int) ($release->version_code ?? ($default['latest_version_code'] ?? $clientCode));
        $downloadUrl = (string) ($release->download_url ?? ($default['download_url'] ?? ''));
        $changelog = (string) ($release->changelog ?? ($default['changelog'] ?? ''));
        $sha256 = (string) ($release->sha256 ?? ($default['sha256'] ?? ''));
        $minSupported = (string) ($release->min_supported_version_name ?? ($default['min_supported_version_name'] ?? $latestVersionName));
        $forceFlag = (bool) ($release->force_update ?? ($default['force_update'] ?? false));

        $hasUpdate = $this->compareVersion($latestVersionName, $clientVersion) > 0;
        $belowMin = $this->compareVersion($minSupported, $clientVersion) > 0;
        $forceUpdate = $hasUpdate && ($forceFlag || $belowMin);

        return response()->json([
            'platform' => $platform,
            'channel' => $channel,
            'client_version_name' => $clientVersion,
            'client_version_code' => $clientCode,
            'latest_version_name' => $latestVersionName,
            'latest_version_code' => $latestVersionCode,
            'min_supported_version_name' => $minSupported,
            'has_update' => $hasUpdate,
            'force_update' => $forceUpdate,
            'download_url' => $downloadUrl,
            'changelog' => $changelog,
            'sha256' => $sha256,
        ]);
    }

    private function compareVersion(string $left, string $right): int
    {
        $l = $this->parseVersion($left);
        $r = $this->parseVersion($right);
        for ($i = 0; $i < 3; $i++) {
            if ($l[$i] > $r[$i]) {
                return 1;
            }
            if ($l[$i] < $r[$i]) {
                return -1;
            }
        }
        return 0;
    }

    /**
     * Version format: major.minor.patch, e.g. 0.01.01
     *
     * @return array{0:int,1:int,2:int}
     */
    private function parseVersion(string $value): array
    {
        if (preg_match('/^\s*(\d+)\.(\d+)\.(\d+)\s*$/', $value, $m) === 1) {
            return [(int) $m[1], (int) $m[2], (int) $m[3]];
        }

        return [0, 0, 0];
    }
}
