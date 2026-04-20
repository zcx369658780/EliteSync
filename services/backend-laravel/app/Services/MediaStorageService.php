<?php

namespace App\Services;

use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Str;
use RuntimeException;

class MediaStorageService
{
    public function __construct(
        protected MediaUploadPolicy $policy
    ) {
    }

    public function disk(): string
    {
        return $this->policy->disk();
    }

    public function provider(): string
    {
        return 'oss';
    }

    public function buildUploadStorageKey(int $userId, string $mediaType, string $originalName): string
    {
        $safeType = preg_replace('/[^a-z0-9_-]+/i', '-', strtolower(trim($mediaType))) ?: 'file';
        $extension = strtolower(pathinfo($originalName, PATHINFO_EXTENSION));
        $safeExtension = preg_replace('/[^a-z0-9]+/i', '', $extension) ?: 'bin';

        return sprintf(
            '%s/%d/%s/%s.%s',
            $this->policy->publicBasePath(),
            $userId,
            $safeType,
            (string) Str::uuid(),
            $safeExtension
        );
    }

    public function storeUploadedFile(UploadedFile $file, string $storageKey): array
    {
        $disk = $this->disk();
        $path = $this->storePath($storageKey);
        $directory = dirname($path);
        $filename = basename($path);
        $storedPath = Storage::disk($disk)->putFileAs($directory === '.' ? '' : $directory, $file, $filename);

        if ($storedPath === false) {
            throw new RuntimeException('failed to write media file to storage');
        }

        $publicUrl = null;
        try {
            $publicUrl = Storage::disk($disk)->url($storedPath);
        } catch (\Throwable) {
            $publicUrl = null;
        }
        if ($this->looksLikeLocalMediaUrl((string) $publicUrl)) {
            $publicUrl = $this->buildRuntimePublicUrl($storedPath);
        }

        return [
            'disk' => $disk,
            'provider' => $this->provider(),
            'storage_key' => $storedPath,
            'public_url' => $publicUrl,
        ];
    }

    protected function storePath(string $storageKey): string
    {
        return ltrim(str_replace('\\', '/', $storageKey), '/');
    }

    protected function buildRuntimePublicUrl(string $storagePath): string
    {
        try {
            $request = request();
            $base = trim((string) $request->getSchemeAndHttpHost());
            if ($base !== '') {
                return rtrim($base, '/') . '/storage/' . ltrim($storagePath, '/');
            }
        } catch (\Throwable) {
            // Fallback to the configured application URL below.
        }

        $appUrl = trim((string) config('app.url'));
        if ($appUrl !== '') {
            return rtrim($appUrl, '/') . '/storage/' . ltrim($storagePath, '/');
        }

        return $storagePath;
    }

    protected function looksLikeLocalMediaUrl(string $url): bool
    {
        $trimmed = trim($url);
        if ($trimmed === '') {
            return true;
        }

        if (str_starts_with($trimmed, '/') || str_starts_with($trimmed, 'file://')) {
            return true;
        }

        if (!str_contains($trimmed, '://')) {
            return true;
        }

        $host = parse_url($trimmed, PHP_URL_HOST);
        if (!is_string($host) || $host === '') {
            return true;
        }

        return in_array(strtolower($host), [
            'localhost',
            '127.0.0.1',
            '::1',
            '10.0.2.2',
        ], true);
    }
}
