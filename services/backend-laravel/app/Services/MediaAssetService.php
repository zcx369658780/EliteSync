<?php

namespace App\Services;

use App\Models\MediaAsset;
use App\Models\MediaProcessingJob;
use App\Models\User;
use App\Jobs\ProcessMediaAssetJob;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Str;
use Throwable;

class MediaAssetService
{
    public function registerDraft(User $user, array $data): MediaAsset
    {
        $disk = (string) config('media.disk', 'public');
        $provider = $this->providerFromDisk($disk);
        $storageKey = $data['storage_key'] ?? $this->draftStorageKey((int) $user->id, (string) ($data['media_type'] ?? 'file'));

        $asset = MediaAsset::query()->create([
            'owner_user_id' => $user->id,
            'media_type' => (string) ($data['media_type'] ?? 'file'),
            'storage_provider' => $provider,
            'storage_disk' => $disk,
            'storage_key' => $storageKey,
            'original_name' => $data['original_name'] ?? null,
            'mime_type' => $data['mime_type'] ?? null,
            'size_bytes' => (int) ($data['size_bytes'] ?? 0),
            'width' => $data['width'] ?? null,
            'height' => $data['height'] ?? null,
            'duration_ms' => $data['duration_ms'] ?? null,
            'sha256' => $data['sha256'] ?? null,
            'status' => !empty($data['public_url']) ? 'uploaded' : 'pending',
            'public_url' => $data['public_url'] ?? null,
            'metadata' => $data['metadata'] ?? null,
            'uploaded_at' => !empty($data['public_url']) ? now() : null,
        ]);

        MediaProcessingJob::query()->create([
            'media_asset_id' => $asset->id,
            'job_type' => 'register',
            'status' => 'queued',
            'attempt_count' => 0,
            'max_attempts' => 3,
            'locked_at' => null,
            'processed_at' => null,
            'payload' => [
                'storage_key' => $storageKey,
                'disk' => $disk,
            ],
        ]);

        return $asset;
    }

    public function registerUploaded(User $user, UploadedFile $file, array $data = []): MediaAsset
    {
        $policy = app(MediaUploadPolicy::class);
        $storage = app(MediaStorageService::class);
        $mimeType = strtolower(trim((string) ($data['mime_type'] ?? $file->getMimeType() ?? '')));
        $sizeBytes = (int) ($data['size_bytes'] ?? $file->getSize() ?? 0);
        $mediaType = (string) ($data['media_type'] ?? $this->mediaTypeFromMime($mimeType));
        $originalName = (string) ($data['original_name'] ?? $file->getClientOriginalName() ?? $file->getFilename() ?? 'upload.bin');
        $storageKey = $data['storage_key'] ?? $storage->buildUploadStorageKey((int) $user->id, $mediaType, $originalName);

        $asset = MediaAsset::query()->create([
            'owner_user_id' => $user->id,
            'media_type' => $mediaType,
            'storage_provider' => $storage->provider(),
            'storage_disk' => $storage->disk(),
            'storage_key' => $storageKey,
            'original_name' => $originalName,
            'mime_type' => $mimeType !== '' ? $mimeType : null,
            'size_bytes' => max(0, $sizeBytes),
            'width' => $data['width'] ?? null,
            'height' => $data['height'] ?? null,
            'duration_ms' => $data['duration_ms'] ?? null,
            'sha256' => $data['sha256'] ?? null,
            'status' => 'uploading',
            'public_url' => null,
            'metadata' => $data['metadata'] ?? null,
            'uploaded_at' => null,
        ]);

        if (!$policy->isAllowedMime($asset->mime_type)) {
            $asset->forceFill([
                'status' => 'blocked',
                'error_code' => 'mime_not_allowed',
                'error_message' => 'mime type is not allowed by media policy',
            ])->save();

            return $asset->refresh();
        }

        if (!$policy->isAllowedSize($asset->size_bytes)) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'upload_too_large',
                'error_message' => 'file size is larger than the configured upload limit',
            ])->save();

            return $asset->refresh();
        }

        try {
            $stored = $storage->storeUploadedFile($file, $asset->storage_key);

            $realPath = $file->getRealPath();

            $asset->forceFill([
                'storage_disk' => $stored['disk'],
                'storage_provider' => $stored['provider'],
                'storage_key' => $stored['storage_key'],
                'public_url' => $stored['public_url'],
                'status' => 'uploaded',
                'uploaded_at' => now(),
                'sha256' => $data['sha256'] ?? ($realPath ? hash_file('sha256', $realPath) : null),
            ])->save();
        } catch (Throwable $e) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'storage_write_failed',
                'error_message' => $e->getMessage(),
            ])->save();

            throw $e;
        }

        MediaProcessingJob::query()->create([
            'media_asset_id' => $asset->id,
            'job_type' => 'register',
            'status' => 'queued',
            'attempt_count' => 0,
            'max_attempts' => 3,
            'locked_at' => null,
            'processed_at' => null,
            'payload' => [
                'storage_key' => $asset->storage_key,
                'disk' => $asset->storage_disk,
            ],
        ]);

        try {
            ProcessMediaAssetJob::dispatchSync($asset->id);
        } catch (Throwable $e) {
            $asset->forceFill([
                'status' => 'failed',
                'error_code' => 'processing_failed',
                'error_message' => $e->getMessage(),
            ])->save();

            throw $e;
        }

        return $asset->refresh();
    }

    public function providerFromDisk(string $disk): string
    {
        return 'oss';
    }

    public function mediaTypeFromMime(?string $mime): string
    {
        $mime = strtolower(trim((string) $mime));
        if (str_starts_with($mime, 'image/')) {
            return 'image';
        }
        if (str_starts_with($mime, 'video/')) {
            return 'video';
        }
        if (str_starts_with($mime, 'audio/')) {
            return 'audio';
        }

        return 'file';
    }

    public function draftStorageKey(int $userId, string $mediaType): string
    {
        $safeType = preg_replace('/[^a-z0-9_-]+/i', '-', strtolower($mediaType)) ?: 'file';

        return sprintf(
            '%s/%d/%s/%s',
            rtrim((string) config('media.public_base_path', 'chat-media'), '/'),
            $userId,
            $safeType,
            (string) Str::uuid()
        );
    }
}
