<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->string('category', 64)->nullable()->after('question_key');
            $table->text('question_text_zh')->nullable()->after('category');
            $table->text('question_text_en')->nullable()->after('question_text_zh');
            $table->string('acceptable_answer_logic', 24)->default('multi_select')->after('question_type');
            $table->unsignedInteger('version')->default(1)->after('enabled');
        });

        Schema::table('questionnaire_answers', function (Blueprint $table) {
            $table->json('selected_answer_json')->nullable()->after('answer_payload');
            $table->json('acceptable_answers_json')->nullable()->after('selected_answer_json');
            $table->unsignedTinyInteger('importance')->nullable()->after('acceptable_answers_json');
            $table->unsignedInteger('version')->default(1)->after('importance');
        });
    }

    public function down(): void
    {
        Schema::table('questionnaire_answers', function (Blueprint $table) {
            $table->dropColumn(['selected_answer_json', 'acceptable_answers_json', 'importance', 'version']);
        });

        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->dropColumn(['category', 'question_text_zh', 'question_text_en', 'acceptable_answer_logic', 'version']);
        });
    }
};

