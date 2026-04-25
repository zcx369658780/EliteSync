<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('rtc_sessions', function (Blueprint $table) {
            $table->timestamp('initiator_last_seen_at')->nullable()->index()->after('started_at');
            $table->timestamp('peer_last_seen_at')->nullable()->index()->after('initiator_last_seen_at');
        });
    }

    public function down(): void
    {
        Schema::table('rtc_sessions', function (Blueprint $table) {
            $table->dropColumn(['initiator_last_seen_at', 'peer_last_seen_at']);
        });
    }
};
