<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('dating_matches', function (Blueprint $table) {
            $table->id();
            $table->string('week_tag', 16)->index();
            $table->foreignId('user_a')->constrained('users')->cascadeOnDelete();
            $table->foreignId('user_b')->constrained('users')->cascadeOnDelete();
            $table->text('highlights')->nullable();
            $table->boolean('drop_released')->default(false);
            $table->boolean('like_a')->nullable();
            $table->boolean('like_b')->nullable();
            $table->timestamps();

            $table->index(['user_a', 'week_tag']);
            $table->index(['user_b', 'week_tag']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('dating_matches');
    }
};
