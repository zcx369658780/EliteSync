<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->boolean('is_synthetic')->default(false)->after('disabled');
            $table->string('synthetic_batch', 64)->nullable()->after('is_synthetic');
            $table->index(['is_synthetic', 'synthetic_batch'], 'users_synthetic_idx');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropIndex('users_synthetic_idx');
            $table->dropColumn(['is_synthetic', 'synthetic_batch']);
        });
    }
};

