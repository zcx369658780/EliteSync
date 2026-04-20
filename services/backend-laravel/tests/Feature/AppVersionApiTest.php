<?php

namespace Tests\Feature;

use App\Models\AppReleaseVersion;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AppVersionApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_app_health_returns_database_status(): void
    {
        $this->getJson('/api/v1/app/health')
            ->assertOk()
            ->assertJsonPath('status', 'ok')
            ->assertJsonPath('checks.database.ok', true)
            ->assertJsonPath('checks.config.ok', true)
            ->assertJsonPath('app_version', '0.04.04');
    }

    public function test_version_check_returns_soft_update(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.01.02',
            'version_code' => 102,
            'min_supported_version_name' => '0.01.01',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.01.02.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.01.01&version_code=101')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', false)
            ->assertJsonPath('latest_version_name', '0.01.02');
    }

    public function test_version_check_returns_force_update_when_below_min_supported(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.01.10',
            'version_code' => 110,
            'min_supported_version_name' => '0.01.05',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.01.10.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.01.01&version_code=101')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('force_update', true);
    }

    public function test_version_check_supports_alpha_suffix_ordering(): void
    {
        AppReleaseVersion::query()->create([
            'platform' => 'android',
            'channel' => 'stable',
            'version_name' => '0.03.02a',
            'version_code' => 30201,
            'min_supported_version_name' => '0.03.01',
            'download_url' => 'https://slowdate.top/downloads/elitesync-0.03.02a.apk',
            'force_update' => false,
            'is_active' => true,
        ]);

        $this->getJson('/api/v1/app/version/check?platform=android&version_name=0.03.02&version_code=302')
            ->assertOk()
            ->assertJsonPath('has_update', true)
            ->assertJsonPath('latest_version_name', '0.03.02a');
    }
}
