<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->string('quality_tier', 16)->default('normal')->after('recommended_bank');
            $table->index('quality_tier');
        });
    }

    public function down(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->dropIndex(['quality_tier']);
            $table->dropColumn('quality_tier');
        });
    }
};
