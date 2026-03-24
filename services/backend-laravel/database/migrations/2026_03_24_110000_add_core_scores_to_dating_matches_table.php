<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            if (!Schema::hasColumn('dating_matches', 'score_personality_total')) {
                $table->unsignedTinyInteger('score_personality_total')->nullable()->after('score_fair');
            }
            if (!Schema::hasColumn('dating_matches', 'score_mbti_total')) {
                $table->unsignedTinyInteger('score_mbti_total')->nullable()->after('score_personality_total');
            }
            if (!Schema::hasColumn('dating_matches', 'score_astro_total')) {
                $table->unsignedTinyInteger('score_astro_total')->nullable()->after('score_mbti_total');
            }
            if (!Schema::hasColumn('dating_matches', 'score_overall')) {
                $table->unsignedTinyInteger('score_overall')->nullable()->after('score_astro_total');
            }
        });
    }

    public function down(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $drop = [];
            foreach (['score_personality_total', 'score_mbti_total', 'score_astro_total', 'score_overall'] as $col) {
                if (Schema::hasColumn('dating_matches', $col)) {
                    $drop[] = $col;
                }
            }
            if (!empty($drop)) {
                $table->dropColumn($drop);
            }
        });
    }
};

