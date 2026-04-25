<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('rtc_sessions', function (Blueprint $table) {
            $table->id();
            $table->string('call_key', 96)->unique();
            $table->string('room_key', 64)->index();
            $table->foreignId('initiator_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('peer_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('mode', 16)->default('voice')->index();
            $table->string('status', 24)->index();
            $table->foreignId('accepted_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->foreignId('ended_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('ringing_at')->nullable()->index();
            $table->timestamp('accepted_at')->nullable()->index();
            $table->timestamp('started_at')->nullable()->index();
            $table->timestamp('ended_at')->nullable()->index();
            $table->timestamp('expires_at')->nullable()->index();
            $table->string('failure_code', 64)->nullable()->index();
            $table->text('failure_message')->nullable();
            $table->json('metadata')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('rtc_sessions');
    }
};
