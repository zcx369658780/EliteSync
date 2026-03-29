<?php

namespace Tests\Unit;

use App\Services\AstroCanonicalRolloutService;
use Illuminate\Support\Facades\Config;
use Tests\TestCase;

class AstroCanonicalRolloutServiceTest extends TestCase
{
    public function test_bazi_platform_override_legacy_blocks_even_when_global_enabled(): void
    {
        Config::set('astro_rollout.bazi', [
            'enabled' => true,
            'whitelist_user_ids' => [9],
            'platform_overrides' => ['android' => 'legacy'],
            'min_profile_version' => 0,
        ]);

        $svc = app(AstroCanonicalRolloutService::class);
        $ret = $svc->decideBazi([
            'user_id' => 9,
            'platform' => 'android',
            'profile_version' => 10,
        ]);

        $this->assertFalse((bool) ($ret['enabled'] ?? true));
        $this->assertSame('bazi_platform_override:legacy', (string) ($ret['reason'] ?? ''));
    }

    public function test_western_whitelist_can_enable_when_global_disabled(): void
    {
        Config::set('astro_rollout.western', [
            'enabled' => false,
            'whitelist_user_ids' => [1001, 1002],
            'platform_overrides' => [],
            'min_profile_version' => 0,
        ]);

        $svc = app(AstroCanonicalRolloutService::class);
        $ret = $svc->decideWestern([
            'user_id' => 1002,
            'platform' => 'android',
            'profile_version' => 1,
        ]);

        $this->assertTrue((bool) ($ret['enabled'] ?? false));
        $this->assertSame('western_whitelist', (string) ($ret['reason'] ?? ''));
    }
}

