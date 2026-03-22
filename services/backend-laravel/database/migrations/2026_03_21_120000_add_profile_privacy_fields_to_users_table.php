<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->date('birthday')->nullable()->after('phone');
            $table->boolean('realname_verified')->default(false)->after('verify_status');

            // Public profile fields: can be shown to matched users.
            $table->string('public_zodiac_sign', 32)->nullable()->after('realname_verified');
            $table->string('public_mbti', 16)->nullable()->after('public_zodiac_sign');
            $table->json('public_personality')->nullable()->after('public_mbti');

            // Private profile fields: never exposed to other users.
            $table->string('private_bazi', 128)->nullable()->after('public_personality');
            $table->json('private_natal_chart')->nullable()->after('private_bazi');
            $table->string('private_birth_place', 255)->nullable()->after('private_natal_chart');
            $table->decimal('private_birth_lat', 10, 7)->nullable()->after('private_birth_place');
            $table->decimal('private_birth_lng', 10, 7)->nullable()->after('private_birth_lat');
        });
    }

    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'birthday',
                'realname_verified',
                'public_zodiac_sign',
                'public_mbti',
                'public_personality',
                'private_bazi',
                'private_natal_chart',
                'private_birth_place',
                'private_birth_lat',
                'private_birth_lng',
            ]);
        });
    }
};

