<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('status_post_likes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('status_post_id')->constrained('status_posts')->cascadeOnDelete();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            $table->unique(['status_post_id', 'user_id']);
            $table->index(['user_id', 'status_post_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('status_post_likes');
    }
};
