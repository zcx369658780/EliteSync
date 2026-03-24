<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (!Schema::hasColumn('users', 'zodiac_animal')) {
                $table->string('zodiac_animal', 8)->nullable()->after('birthday');
                $table->index('zodiac_animal', 'users_zodiac_animal_idx');
            }
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            if (Schema::hasColumn('users', 'zodiac_animal')) {
                $table->dropIndex('users_zodiac_animal_idx');
                $table->dropColumn('zodiac_animal');
            }
        });
    }
};

