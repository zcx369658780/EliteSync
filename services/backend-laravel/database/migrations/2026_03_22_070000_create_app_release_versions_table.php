<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('app_release_versions', function (Blueprint $table) {
            $table->id();
            $table->string('platform', 16); // android / ios
            $table->string('channel', 32)->default('stable');
            $table->string('version_name', 32); // e.g. 0.01.01
            $table->unsignedInteger('version_code')->default(1);
            $table->string('min_supported_version_name', 32)->nullable();
            $table->string('download_url', 512);
            $table->text('changelog')->nullable();
            $table->string('sha256', 128)->nullable();
            $table->boolean('force_update')->default(false);
            $table->boolean('is_active')->default(true);
            $table->timestamp('published_at')->nullable();
            $table->timestamps();

            $table->index(['platform', 'channel', 'is_active'], 'idx_app_release_platform_channel_active');
            $table->unique(['platform', 'channel', 'version_code'], 'uq_app_release_platform_channel_code');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('app_release_versions');
    }
};

