<?php

namespace App\Services;

use App\Models\MediaAsset;
use Illuminate\Support\Facades\Cache;

class MediaCacheService
{
    public function assetSnapshotKey(int $assetId): string
    {
        return "media:asset:{$assetId}:snapshot";
    }

    public function rememberAssetSnapshot(MediaAsset $asset): void
    {
        Cache::put(
            $this->assetSnapshotKey((int) $asset->id),
            [
                'id' => (int) $asset->id,
                'status' => (string) $asset->status,
                'media_type' => (string) $asset->media_type,
                'storage_provider' => (string) $asset->storage_provider,
                'storage_disk' => (string) $asset->storage_disk,
                'storage_key' => (string) $asset->storage_key,
                'public_url' => $asset->public_url,
            ],
            now()->addSeconds((int) config('media.cache_ttl_seconds', 300))
        );
    }

    public function forgetAssetSnapshot(int $assetId): void
    {
        Cache::forget($this->assetSnapshotKey($assetId));
    }
}
