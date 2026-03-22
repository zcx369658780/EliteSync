<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->json('explanation_tags')->nullable()->after('highlights');
        });
    }

    public function down(): void
    {
        Schema::table('dating_matches', function (Blueprint $table) {
            $table->dropColumn('explanation_tags');
        });
    }
};

