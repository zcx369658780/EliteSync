<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            if (!Schema::hasColumn('dating_matches', 'score_bazi')) {
                $table->unsignedTinyInteger('score_bazi')->nullable()->after('score_fair');
                $table->unsignedTinyInteger('score_zodiac')->nullable()->after('score_bazi');
                $table->unsignedTinyInteger('score_constellation')->nullable()->after('score_zodiac');
                $table->unsignedTinyInteger('score_natal_chart')->nullable()->after('score_constellation');
                $table->string('match_verdict', 16)->nullable()->after('score_natal_chart');
                $table->json('match_reasons')->nullable()->after('match_verdict');
            }
        });
    }

    public function down(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            if (Schema::hasColumn('dating_matches', 'match_reasons')) {
                $table->dropColumn([
                    'score_bazi',
                    'score_zodiac',
                    'score_constellation',
                    'score_natal_chart',
                    'match_verdict',
                    'match_reasons',
                ]);
            }
        });
    }
};

