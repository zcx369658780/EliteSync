<?php

namespace Tests\Feature;

use App\Models\MediaAsset;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Storage;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MediaUploadEndpointTest extends TestCase
{
    use RefreshDatabase;

    public function test_media_upload_route_writes_to_object_storage_and_completes_pipeline(): void
    {
        config([
            'media.disk' => 's3',
            'media.max_upload_bytes' => 25 * 1024 * 1024,
            'media.allowed_mime_prefixes' => ['image/', 'video/'],
        ]);

        Storage::fake('s3');

        $user = User::create([
            'phone' => '13800000032',
            'name' => 'Uploader',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->createWithContent(
            'upload.png',
            str_repeat('fake-image-bytes', 256)
        );

        $response = $this->post('/api/v1/media', [
            'media_type' => 'image',
            'original_name' => 'upload.png',
            'mime_type' => 'image/png',
            'metadata' => ['source' => 'feature-test'],
            'file' => $file,
        ]);

        $response->assertOk()
            ->assertJsonPath('domain', 'media')
            ->assertJsonPath('asset.status', 'ready')
            ->assertJsonPath('asset.storage_disk', 's3')
            ->assertJsonPath('asset.storage_provider', 'oss')
            ->assertJsonPath('asset.media_type', 'image');

        $assetId = (int) $response->json('asset.id');
        $asset = MediaAsset::query()->findOrFail($assetId);

        Storage::disk('s3')->assertExists($asset->storage_key);

        $this->assertSame('ready', $asset->status);
        $this->assertNotNull($asset->uploaded_at);
        $this->assertNotNull($asset->processed_at);
        $this->assertNotEmpty($asset->public_url);
        $this->assertDatabaseHas('media_processing_jobs', [
            'media_asset_id' => $assetId,
            'job_type' => 'normalize',
            'status' => 'succeeded',
        ]);
    }

    public function test_media_upload_route_rejects_invalid_mime_with_a_tracked_asset(): void
    {
        Storage::fake('s3');
        config([
            'media.disk' => 's3',
            'media.allowed_mime_prefixes' => ['image/', 'video/'],
        ]);

        $user = User::create([
            'phone' => '13800000033',
            'name' => 'Reject',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);

        $file = UploadedFile::fake()->create('doc.pdf', 32, 'application/pdf');

        $response = $this->post('/api/v1/media', [
            'media_type' => 'file',
            'original_name' => 'doc.pdf',
            'file' => $file,
        ]);

        $response->assertStatus(422)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('asset.status', 'blocked')
            ->assertJsonPath('asset.error_code', 'mime_not_allowed');
    }

    public function test_media_content_route_streams_public_disk_files(): void
    {
        config([
            'app.url' => 'http://101.133.161.203',
            'media.disk' => 'public',
        ]);

        Storage::fake('public');
        Storage::disk('public')->put('chat-media/99/image/sample.png', 'sample-bytes');

        $user = User::create([
            'phone' => '13800000034',
            'name' => 'Viewer',
            'password' => 'secret123',
        ]);

        $asset = MediaAsset::create([
            'owner_user_id' => $user->id,
            'media_type' => 'image',
            'storage_provider' => 'oss',
            'storage_disk' => 'public',
            'storage_key' => 'chat-media/99/image/sample.png',
            'original_name' => 'sample.png',
            'mime_type' => 'image/png',
            'size_bytes' => 12,
            'status' => 'ready',
            'uploaded_at' => now(),
            'processed_at' => now(),
        ]);

        $this->get("/api/v1/media/{$asset->id}/content")
            ->assertOk()
            ->assertHeader('Content-Type', 'image/png');
    }
}
