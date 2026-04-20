<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('questionnaire_attempts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->string('questionnaire_version', 32)->default('q_v2');
            $table->string('bank_version', 32)->default('qb_v1');
            $table->string('attempt_version', 32)->default('qa_v1');
            $table->unsignedInteger('answers_count')->default(0);
            $table->unsignedInteger('total_count')->default(0);
            $table->json('answers_json');
            $table->json('profile_json')->nullable();
            $table->json('summary_json')->nullable();
            $table->string('result_label')->nullable();
            $table->json('result_highlights_json')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->timestamps();

            $table->index(['user_id', 'id']);
            $table->index(['user_id', 'completed_at']);
            $table->index(['user_id', 'questionnaire_version']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('questionnaire_attempts');
    }
};
