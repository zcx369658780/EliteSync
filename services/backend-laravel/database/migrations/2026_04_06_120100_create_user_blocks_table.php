<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_blocks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('blocker_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('blocked_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('reason_code', 64)->nullable();
            $table->text('detail')->nullable();
            $table->timestamps();

            $table->unique(['blocker_id', 'blocked_user_id']);
            $table->index(['blocked_user_id', 'blocker_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_blocks');
    }
};
