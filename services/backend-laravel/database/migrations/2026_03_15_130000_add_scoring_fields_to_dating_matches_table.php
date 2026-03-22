<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->unsignedInteger('score_base')->nullable()->after('explanation_tags');
            $table->unsignedInteger('score_final')->nullable()->after('score_base');
            $table->unsignedInteger('score_fair')->nullable()->after('score_final');
            $table->json('penalty_factors')->nullable()->after('score_fair');
        });
    }

    public function down(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->dropColumn(['score_base', 'score_final', 'score_fair', 'penalty_factors']);
        });
    }
};

