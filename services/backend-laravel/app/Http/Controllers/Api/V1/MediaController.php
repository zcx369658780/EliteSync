<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Jobs\ProcessMediaAssetJob;
use App\Models\MediaAsset;
use App\Services\MediaAssetService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;
use Throwable;

class MediaController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = MediaAsset::query()
            ->where('owner_user_id', $request->user()->id)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'items' => $items,
            'total' => $items->count(),
            'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
        ]);
    }

    public function store(Request $request, MediaAssetService $service): JsonResponse
    {
        $data = $request->validate([
            'media_type' => ['required', 'string', 'max:24'],
            'file' => ['nullable', 'file'],
            'original_name' => ['nullable', 'string', 'max:255'],
            'mime_type' => ['nullable', 'string', 'max:128'],
            'size_bytes' => ['nullable', 'integer', 'min:0'],
            'width' => ['nullable', 'integer', 'min:0'],
            'height' => ['nullable', 'integer', 'min:0'],
            'duration_ms' => ['nullable', 'integer', 'min:0'],
            'sha256' => ['nullable', 'string', 'size:64'],
            'storage_key' => ['nullable', 'string', 'max:255'],
            'public_url' => ['nullable', 'string', 'max:512'],
            'metadata' => ['nullable', 'array'],
        ]);

        try {
            if ($request->hasFile('file')) {
                $file = $request->file('file');
                $data['mime_type'] = (string) ($data['mime_type'] ?? $file?->getMimeType() ?? '');
                $data['size_bytes'] = (int) ($data['size_bytes'] ?? $file?->getSize() ?? 0);

                $asset = $service->registerUploaded($request->user(), $file, $data);
            } else {
                $asset = $service->registerDraft($request->user(), $data);
            }
        } catch (Throwable $e) {
            Log::error('media_upload_failed', [
                'owner_user_id' => (int) $request->user()->id,
                'media_type' => (string) ($data['media_type'] ?? 'file'),
                'message' => $e->getMessage(),
            ]);

            return response()->json([
                'ok' => false,
                'domain' => 'media',
                'message' => 'media upload failed',
            ], 500);
        }

        Log::info('media_asset_saved', [
            'asset_id' => (int) $asset->id,
            'owner_user_id' => (int) $request->user()->id,
            'media_type' => (string) $asset->media_type,
            'storage_disk' => (string) $asset->storage_disk,
        ]);

        if (in_array((string) $asset->error_code, ['mime_not_allowed', 'upload_too_large'], true)) {
            return response()->json([
                'ok' => false,
                'domain' => 'media',
                'message' => (string) ($asset->error_message ?? 'media upload rejected'),
                'asset' => $asset,
                'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
            ], 422);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'asset' => $asset,
            'states' => ['pending', 'uploading', 'uploaded', 'processing', 'ready', 'failed', 'blocked', 'deleted'],
        ]);
    }

    public function show(Request $request, int $assetId): JsonResponse
    {
        $asset = MediaAsset::query()
            ->where('owner_user_id', $request->user()->id)
            ->find($assetId);

        if (!$asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'media',
            'asset' => $asset,
        ]);
    }

    public function content(int $assetId)
    {
        $asset = MediaAsset::query()->find($assetId);

        if (!$asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        try {
            $disk = Storage::disk((string) $asset->storage_disk);
            $storageKey = (string) $asset->storage_key;

            if ($storageKey !== '') {
                $path = method_exists($disk, 'path') ? $disk->path($storageKey) : null;
                if (is_string($path) && $path !== '' && is_file($path)) {
                    return response()->file($path, [
                        'Content-Type' => (string) ($asset->mime_type ?? 'application/octet-stream'),
                        'Cache-Control' => 'public, max-age=300',
                    ]);
                }

                if (method_exists($disk, 'response')) {
                    return $disk->response($storageKey, null, [
                        'Content-Type' => (string) ($asset->mime_type ?? 'application/octet-stream'),
                        'Cache-Control' => 'public, max-age=300',
                    ]);
                }
            }
        } catch (Throwable $e) {
            Log::warning('media_content_stream_failed', [
                'asset_id' => (int) $asset->id,
                'message' => $e->getMessage(),
            ]);
        }

        return response()->json([
            'message' => 'media asset unavailable',
        ], 404);
    }

    public function processDemo(Request $request, int $assetId): JsonResponse
    {
        $asset = MediaAsset::query()
            ->where('owner_user_id', $request->user()->id)
            ->find($assetId);

        if (!$asset) {
            return response()->json(['message' => 'media asset not found'], 404);
        }

        Log::info('media_process_demo_triggered', [
            'asset_id' => (int) $asset->id,
            'owner_user_id' => (int) $request->user()->id,
        ]);

        ProcessMediaAssetJob::dispatchSync($asset->id);

        return response()->json([
            'ok' => true,
            'queued' => true,
            'asset_id' => (int) $asset->id,
            'queue_name' => (string) config('media.queue_name', 'media'),
        ]);
    }
}
