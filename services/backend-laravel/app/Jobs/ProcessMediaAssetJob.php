<?php

namespace App\Jobs;

use App\Models\MediaAsset;
use App\Models\MediaProcessingJob;
use App\Services\MediaCacheService;
use App\Services\MediaStateMachine;
use App\Services\MediaUploadPolicy;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Bus\Dispatchable;
use Illuminate\Queue\InteractsWithQueue;
use Illuminate\Queue\SerializesModels;

class ProcessMediaAssetJob implements ShouldQueue
{
    use Dispatchable;
    use InteractsWithQueue;
    use Queueable;
    use SerializesModels;

    public function __construct(public int $mediaAssetId)
    {
    }

    public function handle(
        MediaStateMachine $stateMachine,
        MediaUploadPolicy $policy,
        MediaCacheService $cache
    ): void {
        $asset = MediaAsset::query()->find($this->mediaAssetId);
        if (!$asset) {
            return;
        }

        $processingJob = MediaProcessingJob::create([
            'media_asset_id' => (int) $asset->id,
            'job_type' => 'normalize',
            'status' => 'running',
            'attempt_count' => 1,
            'max_attempts' => 3,
            'locked_at' => now(),
            'processed_at' => null,
            'payload' => [
                'source_status' => (string) $asset->status,
                'storage_provider' => (string) $asset->storage_provider,
                'storage_disk' => (string) $asset->storage_disk,
            ],
        ]);

        if (!$policy->isAllowedMime($asset->mime_type)) {
            $asset->forceFill([
                'status' => 'blocked',
                'error_code' => 'mime_not_allowed',
            ])->save();

            $processingJob->forceFill([
                'status' => 'failed',
                'error_code' => 'mime_not_allowed',
                'error_message' => 'mime type is not allowed by media policy',
                'processed_at' => now(),
            ])->save();

            $cache->forgetAssetSnapshot((int) $asset->id);
            return;
        }

        if ($stateMachine->canTransition((string) $asset->status, 'processing')) {
            $asset->forceFill([
                'status' => 'processing',
            ])->save();
        }

        $asset->forceFill([
            'status' => 'ready',
            'processed_at' => now(),
        ])->save();

        $processingJob->forceFill([
            'status' => 'succeeded',
            'processed_at' => now(),
        ])->save();

        $cache->rememberAssetSnapshot($asset->refresh());
    }
}
