<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_astro_profiles', function (Blueprint $table): void {
            if (!Schema::hasColumn('user_astro_profiles', 'ziwei')) {
                $table->json('ziwei')->nullable()->after('wu_xing');
            }
        });

        Schema::table('users', function (Blueprint $table): void {
            if (!Schema::hasColumn('users', 'private_ziwei')) {
                $table->json('private_ziwei')->nullable()->after('private_natal_chart');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table): void {
            if (Schema::hasColumn('users', 'private_ziwei')) {
                $table->dropColumn('private_ziwei');
            }
        });

        Schema::table('user_astro_profiles', function (Blueprint $table): void {
            if (Schema::hasColumn('user_astro_profiles', 'ziwei')) {
                $table->dropColumn('ziwei');
            }
        });
    }
};
