<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('role', 32)->default('user')->after('password');
            $table->string('account_type', 32)->default('normal')->after('role');
            $table->boolean('is_match_eligible')->default(true)->after('account_type');
            $table->boolean('is_square_visible')->default(true)->after('is_match_eligible');
            $table->boolean('exclude_from_metrics')->default(false)->after('is_square_visible');
            $table->string('banned_reason', 255)->nullable()->after('exclude_from_metrics');
            $table->index(['role', 'account_type'], 'users_role_account_type_idx');
            $table->index(['is_match_eligible', 'is_square_visible', 'exclude_from_metrics'], 'users_visibility_metrics_idx');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_role_account_type_idx');
            $table->dropIndex('users_visibility_metrics_idx');
            $table->dropColumn([
                'role',
                'account_type',
                'is_match_eligible',
                'is_square_visible',
                'exclude_from_metrics',
                'banned_reason',
            ]);
        });
    }
};
