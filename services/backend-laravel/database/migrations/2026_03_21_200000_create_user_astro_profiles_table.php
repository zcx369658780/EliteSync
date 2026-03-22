<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_astro_profiles', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->unique()->constrained('users')->cascadeOnDelete();
            $table->string('birth_time', 5);
            $table->string('birth_place', 255)->nullable();
            $table->decimal('birth_lat', 10, 7)->nullable();
            $table->decimal('birth_lng', 10, 7)->nullable();
            $table->string('sun_sign', 32);
            $table->string('moon_sign', 32)->nullable();
            $table->string('asc_sign', 32)->nullable();
            $table->string('bazi', 128)->nullable();
            $table->string('true_solar_time', 32)->nullable();
            $table->json('notes')->nullable();
            $table->timestamp('computed_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_astro_profiles');
    }
};

