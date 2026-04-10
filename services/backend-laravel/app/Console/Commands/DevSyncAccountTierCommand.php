<?php

namespace App\Console\Commands;

use App\Models\User;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Schema;

class DevSyncAccountTierCommand extends Command
{
    protected $signature = 'app:dev:sync-account-tier
        {--only-smoke=1 : Sync current Smoke% accounts as test accounts}
        {--include-admins=1 : Sync configured admin phones as admin role}';

    protected $description = 'Sync account role / type / visibility fields for smoke and admin accounts.';

    public function handle(): int
    {
        $onlySmoke = filter_var((string) $this->option('only-smoke'), FILTER_VALIDATE_BOOL);
        $includeAdmins = filter_var((string) $this->option('include-admins'), FILTER_VALIDATE_BOOL);

        $updated = 0;

        if ($onlySmoke) {
            $payload = [
                'role' => 'user',
                'account_type' => 'test',
                'is_match_eligible' => true,
                'is_square_visible' => true,
                'exclude_from_metrics' => true,
            ];
            if (Schema::hasColumn('users', 'account_status')) {
                $payload['account_status'] = 'active';
            }
            if (Schema::hasColumn('users', 'visibility_scope')) {
                $payload['visibility_scope'] = 'square';
            }
            $updated += User::query()
                ->where('name', 'like', 'Smoke%')
                ->update($payload);
        }

        if ($includeAdmins) {
            $adminPhones = config('app.admin_phones', []);
            if (!empty($adminPhones)) {
                $payload = [
                    'role' => 'admin',
                    'account_type' => 'normal',
                    'is_match_eligible' => false,
                    'is_square_visible' => false,
                    'exclude_from_metrics' => true,
                ];
                if (Schema::hasColumn('users', 'account_status')) {
                    $payload['account_status'] = 'active';
                }
                if (Schema::hasColumn('users', 'visibility_scope')) {
                    $payload['visibility_scope'] = 'hidden';
                }
                $updated += User::query()
                    ->whereIn('phone', $adminPhones)
                    ->update($payload);
            }
        }

        $this->info("Synced account tier fields for {$updated} users");

        return self::SUCCESS;
    }
}
