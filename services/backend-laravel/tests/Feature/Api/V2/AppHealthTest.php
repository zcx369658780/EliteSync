<?php

namespace Tests\Feature\Api\V2;

use Tests\TestCase;

class AppHealthTest extends TestCase
{
    public function test_v2_app_health_returns_static_framework_level_health(): void
    {
        $this->getJson('/api/v2/app/health')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'ok')
            ->assertJsonPath('data.api_version', 'v2')
            ->assertJsonPath('data.service', 'elitesync-backend')
            ->assertJsonPath('data.runtime_stage', '6.0-A1-narrow-v2-skeleton')
            ->assertJsonPath('data.checks.database', 'not_checked')
            ->assertJsonPath('data.checks.redis', 'not_checked')
            ->assertJsonPath('data.checks.storage', 'not_checked');
    }
}
