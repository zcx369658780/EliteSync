<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_assets', function (Blueprint $table) {
            $table->id();
            $table->foreignId('owner_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('media_type', 24)->index();
            $table->string('storage_provider', 24)->default('s3')->index();
            $table->string('storage_disk', 24)->default('public')->index();
            $table->string('storage_key', 255)->unique();
            $table->string('original_name', 255)->nullable();
            $table->string('mime_type', 128)->nullable()->index();
            $table->unsignedBigInteger('size_bytes')->default(0);
            $table->unsignedInteger('width')->nullable();
            $table->unsignedInteger('height')->nullable();
            $table->unsignedInteger('duration_ms')->nullable();
            $table->string('sha256', 64)->nullable()->index();
            $table->string('status', 24)->default('pending')->index();
            $table->string('error_code', 64)->nullable()->index();
            $table->text('error_message')->nullable();
            $table->string('public_url', 512)->nullable();
            $table->json('metadata')->nullable();
            $table->timestamp('uploaded_at')->nullable()->index();
            $table->timestamp('processed_at')->nullable()->index();
            $table->timestamps();
            $table->softDeletes();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_assets');
    }
};
