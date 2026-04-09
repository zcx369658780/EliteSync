<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('status_posts', function (Blueprint $table) {
            $table->id();
            $table->foreignId('author_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('title', 120);
            $table->text('body');
            $table->string('location_name', 120)->nullable();
            $table->string('visibility', 24)->default('public');
            $table->boolean('is_deleted')->default(false);
            $table->foreignId('deleted_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('deleted_at')->nullable();
            $table->timestamps();

            $table->index(['visibility', 'is_deleted', 'created_at'], 'status_posts_visibility_idx');
            $table->index(['author_user_id', 'created_at'], 'status_posts_author_idx');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('status_posts');
    }
};
