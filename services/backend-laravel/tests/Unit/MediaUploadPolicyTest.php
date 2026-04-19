<?php

namespace Tests\Unit;

use App\Services\MediaUploadPolicy;
use Tests\TestCase;

class MediaUploadPolicyTest extends TestCase
{
    public function test_media_upload_policy_reads_config_and_validates_mime(): void
    {
        config([
            'media.disk' => 's3',
            'media.max_upload_bytes' => 123,
            'media.allowed_mime_prefixes' => ['image/', 'video/'],
            'media.public_base_path' => 'chat-media',
        ]);

        $policy = new MediaUploadPolicy();

        $this->assertSame('s3', $policy->disk());
        $this->assertSame(123, $policy->maxUploadBytes());
        $this->assertSame(['image/', 'video/'], $policy->allowedMimePrefixes());
        $this->assertSame('chat-media', $policy->publicBasePath());
        $this->assertTrue($policy->isAllowedMime('image/png'));
        $this->assertTrue($policy->isAllowedMime('video/mp4'));
        $this->assertFalse($policy->isAllowedMime('application/pdf'));
        $this->assertTrue($policy->isAllowedSize(123));
        $this->assertFalse($policy->isAllowedSize(124));
    }
}
