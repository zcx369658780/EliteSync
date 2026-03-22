<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->string('quality_tag', 16)->default('pass')->after('quality_tier');
            $table->index('quality_tag');
        });
    }

    public function down(): void
    {
        Schema::table('questionnaire_questions', function (Blueprint $table) {
            $table->dropIndex(['quality_tag']);
            $table->dropColumn('quality_tag');
        });
    }
};
