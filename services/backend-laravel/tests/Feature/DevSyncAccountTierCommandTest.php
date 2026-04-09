<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class DevSyncAccountTierCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_sync_account_tier_marks_smoke_users_as_test_accounts(): void
    {
        config()->set('app.admin_phones', ['18000000000']);

        $smoke = User::create([
            'phone' => '17094346566',
            'name' => 'SmokeUser',
            'password' => 'secret123',
            'disabled' => false,
            'is_synthetic' => false,
        ]);

        $admin = User::create([
            'phone' => '18000000000',
            'name' => 'AdminUser',
            'password' => 'secret123',
            'disabled' => false,
            'is_synthetic' => false,
        ]);

        $code = Artisan::call('app:dev:sync-account-tier', [
            '--only-smoke' => 1,
            '--include-admins' => 1,
        ]);

        $this->assertSame(0, $code);

        $smoke->refresh();
        $admin->refresh();

        $this->assertSame('user', $smoke->role);
        $this->assertSame('test', $smoke->account_type);
        $this->assertTrue((bool) $smoke->is_match_eligible);
        $this->assertTrue((bool) $smoke->is_square_visible);
        $this->assertTrue((bool) $smoke->exclude_from_metrics);

        $this->assertSame('admin', $admin->role);
        $this->assertSame('normal', $admin->account_type);
        $this->assertFalse((bool) $admin->is_match_eligible);
        $this->assertFalse((bool) $admin->is_square_visible);
        $this->assertTrue((bool) $admin->exclude_from_metrics);
    }
}
