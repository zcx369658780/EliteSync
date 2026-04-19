<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('moderation_reports', function (Blueprint $table) {
            if (!Schema::hasColumn('moderation_reports', 'target_status_post_id')) {
                $table->foreignId('target_status_post_id')
                    ->nullable()
                    ->after('target_message_id')
                    ->constrained('status_posts')
                    ->nullOnDelete();

                $table->index(['target_status_post_id', 'status'], 'moderation_reports_status_post_idx');
            }
        });
    }

    public function down(): void
    {
        Schema::table('moderation_reports', function (Blueprint $table) {
            if (Schema::hasColumn('moderation_reports', 'target_status_post_id')) {
                $table->dropIndex('moderation_reports_status_post_idx');
                $table->dropConstrainedForeignId('target_status_post_id');
            }
        });
    }
};
