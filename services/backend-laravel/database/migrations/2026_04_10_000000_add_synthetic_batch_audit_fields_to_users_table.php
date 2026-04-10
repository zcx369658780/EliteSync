<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('synthetic_batch_id', 64)->nullable()->after('synthetic_batch');
            $table->unsignedBigInteger('synthetic_seed')->nullable()->after('synthetic_batch_id');
            $table->string('generation_version', 32)->default('v1')->after('synthetic_seed');
            $table->string('account_status', 32)->default('active')->after('generation_version');
            $table->string('visibility_scope', 32)->default('square')->after('account_status');
            $table->string('cleanup_token', 64)->nullable()->after('visibility_scope');

            $table->index(['is_synthetic', 'synthetic_batch_id'], 'users_synthetic_batch_id_idx');
            $table->index(['synthetic_batch_id', 'account_status'], 'users_synthetic_batch_status_idx');
            $table->index(['account_status', 'visibility_scope'], 'users_account_visibility_idx');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_synthetic_batch_id_idx');
            $table->dropIndex('users_synthetic_batch_status_idx');
            $table->dropIndex('users_account_visibility_idx');
            $table->dropColumn([
                'synthetic_batch_id',
                'synthetic_seed',
                'generation_version',
                'account_status',
                'visibility_scope',
                'cleanup_token',
            ]);
        });
    }
};
