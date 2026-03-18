<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->string('subtopic', 64)->nullable()->after('category');
            $table->string('recommended_bank', 24)->default('core')->after('subtopic');
        });
    }

    public function down(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->dropColumn(['subtopic', 'recommended_bank']);
        });
    }
};

