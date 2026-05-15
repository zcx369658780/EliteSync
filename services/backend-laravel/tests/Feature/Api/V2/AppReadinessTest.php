<?php

namespace Tests\Feature\Api\V2;

use Tests\TestCase;

class AppReadinessTest extends TestCase
{
    public function test_v2_app_readiness_stays_conservative(): void
    {
        $this->getJson('/api/v2/app/readiness')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'not_ready')
            ->assertJsonPath('data.production_ready', false)
            ->assertJsonPath('data.checks.database.status', 'not_allowed_in_first_slice')
            ->assertJsonPath('data.checks.redis.status', 'not_allowed_in_first_slice')
            ->assertJsonPath('data.checks.queue.status', 'worker_not_resident')
            ->assertJsonPath('data.checks.monitoring.status', 'not_configured')
            ->assertJsonPath('data.checks.backup.status', 'planning_only')
            ->assertJsonPath('data.checks.load_test.status', 'not_executed');
    }
}
