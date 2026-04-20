<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('user_relationship_events', function (Blueprint $table) {
            $table->id();
            $table->foreignId('actor_user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('subject_user_id')->constrained('users')->cascadeOnDelete();
            $table->string('event_type', 32)->index();
            $table->string('status', 24)->default('recorded')->index();
            $table->json('metadata')->nullable();
            $table->timestamp('happened_at')->nullable()->index();
            $table->timestamps();

            $table->index(['actor_user_id', 'subject_user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('user_relationship_events');
    }
};
