<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\DB;
use Tests\TestCase;

class CleanupCalibrationInjectedCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_cleanup_command_removes_marked_rows(): void
    {
        $this->seed();

        $a = User::create([
            'phone' => '13800007771',
            'name' => 'cleanup-a',
            'password' => 'secret123',
        ]);
        $b = User::create([
            'phone' => '13800007772',
            'name' => 'cleanup-b',
            'password' => 'secret123',
        ]);

        $m = DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => min($a->id, $b->id),
            'user_b' => max($a->id, $b->id),
            'drop_released' => true,
            'match_reasons' => ['summary' => 'test'],
        ]);

        $room = min($a->id, $b->id).'_'.max($a->id, $b->id);
        DB::table('chat_messages')->insert([
            'room_id' => $room,
            'sender_id' => $a->id,
            'receiver_id' => $b->id,
            'content' => '[[calibration_injector]] hello',
            'is_read' => false,
            'created_at' => now(),
            'updated_at' => now(),
        ]);

        AppEvent::create([
            'event_name' => 'match_explanation_view_calibration',
            'actor_user_id' => $a->id,
            'target_user_id' => $b->id,
            'match_id' => $m->id,
            'payload' => ['source' => 'calibration_injector'],
        ]);

        $code = Artisan::call('app:dev:cleanup-calibration-injected', [
            '--days' => 60,
            '--limit' => 50,
        ]);
        $this->assertSame(0, $code);

        $this->assertSame(0, (int) DB::table('chat_messages')->where('room_id', $room)->count());
        $this->assertFalse(AppEvent::query()->where('match_id', $m->id)->exists());
    }
}

