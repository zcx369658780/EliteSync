<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('mbti_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('version_code', 32)->default('lite3_v1');
            $table->json('answers_json');
            $table->json('score_json');
            $table->json('confidence_json')->nullable();
            $table->json('tie_break_log_json')->nullable();
            $table->string('result_letters', 8);
            $table->timestamp('submitted_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'id']);
            $table->index(['user_id', 'version_code']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('mbti_attempts');
    }
};

