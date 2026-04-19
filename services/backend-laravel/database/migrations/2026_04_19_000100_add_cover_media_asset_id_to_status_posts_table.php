<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('status_posts', function (Blueprint $table) {
            if (!Schema::hasColumn('status_posts', 'cover_media_asset_id')) {
                $table->foreignId('cover_media_asset_id')
                    ->nullable()
                    ->after('author_user_id')
                    ->constrained('media_assets')
                    ->nullOnDelete();

                $table->index(['cover_media_asset_id', 'created_at'], 'status_posts_cover_media_idx');
            }
        });
    }

    public function down(): void
    {
        Schema::table('status_posts', function (Blueprint $table) {
            if (Schema::hasColumn('status_posts', 'cover_media_asset_id')) {
                $table->dropIndex('status_posts_cover_media_idx');
                $table->dropConstrainedForeignId('cover_media_asset_id');
            }
        });
    }
};
