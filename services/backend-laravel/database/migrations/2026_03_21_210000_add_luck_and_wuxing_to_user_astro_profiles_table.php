<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('user_astro_profiles', function (Blueprint $table) {
            $table->json('da_yun')->nullable()->after('true_solar_time');
            $table->json('liu_nian')->nullable()->after('da_yun');
            $table->json('wu_xing')->nullable()->after('liu_nian');
        });
    }

    public function down(): void
    {
        Schema::table('user_astro_profiles', function (Blueprint $table) {
            $table->dropColumn(['da_yun', 'liu_nian', 'wu_xing']);
        });
    }
};

