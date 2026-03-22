<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->string('quality_reason', 48)->default('standard_discrimination')->after('quality_tag');
            $table->index('quality_reason');
        });
    }

    public function down(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->dropIndex(['quality_reason']);
            $table->dropColumn('quality_reason');
        });
    }
};
