<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('media_processing_jobs', function (Blueprint $table) {
            $table->id();
            $table->foreignId('media_asset_id')->constrained('media_assets')->cascadeOnDelete();
            $table->string('job_type', 32)->default('normalize')->index();
            $table->string('status', 24)->default('pending')->index();
            $table->unsignedSmallInteger('attempt_count')->default(0);
            $table->unsignedSmallInteger('max_attempts')->default(3);
            $table->timestamp('locked_at')->nullable()->index();
            $table->timestamp('processed_at')->nullable()->index();
            $table->string('error_code', 64)->nullable()->index();
            $table->text('error_message')->nullable();
            $table->json('payload')->nullable();
            $table->timestamps();

            $table->index(['status', 'job_type']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('media_processing_jobs');
    }
};
