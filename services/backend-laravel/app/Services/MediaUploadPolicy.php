<?php

namespace App\Services;

class MediaUploadPolicy
{
    public function disk(): string
    {
        return (string) config('media.disk', 'public');
    }

    public function maxUploadBytes(): int
    {
        return (int) config('media.max_upload_bytes', 25 * 1024 * 1024);
    }

    public function allowedMimePrefixes(): array
    {
        return (array) config('media.allowed_mime_prefixes', ['image/', 'video/']);
    }

    public function publicBasePath(): string
    {
        return (string) config('media.public_base_path', 'chat-media');
    }

    public function isAllowedMime(?string $mime): bool
    {
        $mime = strtolower(trim((string) $mime));
        if ($mime === '') {
            return false;
        }

        foreach ($this->allowedMimePrefixes() as $prefix) {
            $prefix = strtolower(trim((string) $prefix));
            if ($prefix !== '' && str_starts_with($mime, $prefix)) {
                return true;
            }
        }

        return false;
    }

    public function isAllowedSize(int $sizeBytes): bool
    {
        if ($sizeBytes < 0) {
            return false;
        }

        return $sizeBytes <= $this->maxUploadBytes();
    }
}
