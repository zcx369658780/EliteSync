<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Casts\Attribute;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;

class MediaAsset extends Model
{
    use HasFactory;
    use SoftDeletes;

    protected $fillable = [
        'owner_user_id',
        'media_type',
        'storage_provider',
        'storage_disk',
        'storage_key',
        'original_name',
        'mime_type',
        'size_bytes',
        'width',
        'height',
        'duration_ms',
        'sha256',
        'status',
        'error_code',
        'error_message',
        'public_url',
        'metadata',
        'uploaded_at',
        'processed_at',
    ];

    protected function casts(): array
    {
        return [
            'size_bytes' => 'integer',
            'width' => 'integer',
            'height' => 'integer',
            'duration_ms' => 'integer',
            'metadata' => 'array',
            'uploaded_at' => 'datetime',
            'processed_at' => 'datetime',
        ];
    }

    public function owner(): BelongsTo
    {
        return $this->belongsTo(User::class, 'owner_user_id');
    }

    protected function publicUrl(): Attribute
    {
        return Attribute::make(
            get: function ($value, array $attributes): string {
                $raw = trim((string) ($value ?? ''));
                if ($raw === '') {
                    return $this->resolvePublicUrlFromStorage($attributes);
                }

                if ($this->shouldRouteStoredUrlToContent($raw, $attributes)) {
                    return $this->resolveContentRouteUrl($attributes);
                }

                if (!$this->looksLikeLocalMediaUrl($raw)) {
                    return $raw;
                }

                return $this->resolvePublicUrlFromStorage($attributes, $raw);
            },
            set: fn ($value) => ['public_url' => $value],
        );
    }

    /**
     * @param array<string, mixed> $attributes
     */
    protected function resolvePublicUrlFromStorage(array $attributes, string $fallback = ''): string
    {
        $disk = trim((string) ($attributes['storage_disk'] ?? ''));
        $storageKey = trim((string) ($attributes['storage_key'] ?? ''));
        $assetId = (int) ($attributes['id'] ?? $this->id ?? 0);

        if ($this->shouldUseContentRoute($disk, $assetId) && $storageKey !== '') {
            $contentRoute = $this->resolveContentRouteUrl($attributes);
            if ($contentRoute !== '') {
                return $contentRoute;
            }
        }

        if ($disk !== '' && $storageKey !== '') {
            try {
                $resolved = (string) Storage::disk($disk)->url($storageKey);
                if (trim($resolved) !== '' && !$this->looksLikeLocalMediaUrl($resolved)) {
                    return $resolved;
                }
            } catch (\Throwable) {
                // Fall back to the stored value when the configured disk cannot resolve a public URL.
            }
        }

        $runtime = $this->runtimePublicBaseUrl();
        if ($runtime !== '' && $storageKey !== '') {
            return rtrim($runtime, '/') . '/storage/' . ltrim($storageKey, '/');
        }

        return $fallback;
    }

    /**
     * @param array<string, mixed> $attributes
     */
    protected function resolveContentRouteUrl(array $attributes): string
    {
        $assetId = (int) ($attributes['id'] ?? $this->id ?? 0);
        if ($assetId <= 0) {
            return '';
        }

        $runtime = $this->runtimePublicBaseUrl();
        if ($runtime === '') {
            return '';
        }

        return rtrim($runtime, '/') . '/api/v1/media/' . $assetId . '/content';
    }

    /**
     * @param array<string, mixed> $attributes
     */
    protected function shouldRouteStoredUrlToContent(string $raw, array $attributes): bool
    {
        $disk = trim((string) ($attributes['storage_disk'] ?? ''));
        if (!$this->shouldUseContentRoute($disk, (int) ($attributes['id'] ?? $this->id ?? 0))) {
            return false;
        }

        $path = parse_url($raw, PHP_URL_PATH);
        if (!is_string($path)) {
            $path = $raw;
        }

        return str_starts_with(ltrim($path, '/'), 'storage/')
            || str_contains($path, '/storage/');
    }

    protected function shouldUseContentRoute(string $disk, int $assetId): bool
    {
        if ($assetId <= 0) {
            return false;
        }

        return in_array(strtolower(trim($disk)), ['public', 'local'], true);
    }

    protected function runtimePublicBaseUrl(): string
    {
        try {
            $request = request();
            $base = trim((string) $request->getSchemeAndHttpHost());
            if ($base !== '') {
                return $base;
            }
        } catch (\Throwable) {
            // Fall back to configured app URL below.
        }

        $appUrl = trim((string) config('app.url'));
        if ($appUrl === '') {
            return '';
        }

        return rtrim($appUrl, '/');
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
