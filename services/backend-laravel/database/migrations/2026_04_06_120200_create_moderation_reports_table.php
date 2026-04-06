<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('moderation_reports', function (Blueprint $table) {
            $table->id();
            $table->foreignId('reporter_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('target_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('target_message_id')->nullable()->constrained('chat_messages')->nullOnDelete();
            $table->string('category', 32);
            $table->string('reason_code', 64);
            $table->text('detail')->nullable();
            $table->string('status', 32)->default('new');
            $table->string('appeal_status', 32)->default('none');
            $table->text('appeal_note')->nullable();
            $table->timestamp('appealed_at')->nullable();
            $table->text('admin_note')->nullable();
            $table->foreignId('resolved_by_user_id')->nullable()->constrained('users')->nullOnDelete();
            $table->timestamp('resolved_at')->nullable();
            $table->timestamps();

            $table->index(['reporter_id', 'status']);
            $table->index(['target_user_id', 'status']);
            $table->index(['category', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('moderation_reports');
    }
};
