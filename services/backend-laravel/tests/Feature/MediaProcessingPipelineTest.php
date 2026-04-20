<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\MediaProcessingJob;
use App\Models\User;
use App\Services\MediaCacheService;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MediaProcessingPipelineTest extends TestCase
{
    use RefreshDatabase;

    public function test_media_processing_demo_route_drives_queue_and_cache(): void
    {
        $user = User::create([
            'phone' => '13800000031',
            'name' => 'Media',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $register = $this->postJson('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'demo.png',
            'mime_type' => 'image/png',
            'size_bytes' => 1024,
            'storage_key' => 'chat-media/demo.png',
            'public_url' => null,
            'metadata' => ['source' => 'test'],
        ])->assertOk()->json();

        $assetId = (int) $register['asset']['id'];

        $this->postJson("/api/v1/media/{$assetId}/process-demo")
            ->assertOk()
            ->assertJsonPath('queued', true)
            ->assertJsonPath('queue_name', config('media.queue_name', 'media'));

        $asset = MediaAsset::query()->findOrFail($assetId);
        $this->assertSame('ready', $asset->status);
        $this->assertNotNull($asset->processed_at);

        $this->assertDatabaseHas('media_processing_jobs', [
            'media_asset_id' => $assetId,
            'job_type' => 'normalize',
            'status' => 'succeeded',
        ]);

        $cache = app(MediaCacheService::class);
        $snapshot = cache()->get($cache->assetSnapshotKey($assetId));
        $this->assertIsArray($snapshot);
        $this->assertSame('ready', $snapshot['status']);
        $this->assertSame('oss', $snapshot['storage_provider']);
    }
}
