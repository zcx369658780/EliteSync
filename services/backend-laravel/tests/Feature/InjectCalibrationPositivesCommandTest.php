<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class InjectCalibrationPositivesCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_inject_command_writes_positive_signals(): void
    {
        $this->seed();
        config()->set('matching.calibration_injector.enabled', true);

        $a = User::create([
            'phone' => '13800008881',
            'name' => 'inject-a',
            'password' => 'secret123',
        ]);
        $b = User::create([
            'phone' => '13800008882',
            'name' => 'inject-b',
            'password' => 'secret123',
        ]);

        $m = DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => min($a->id, $b->id),
            'user_b' => max($a->id, $b->id),
            'drop_released' => true,
            'like_a' => false,
            'like_b' => false,
            'match_reasons' => ['summary' => 'test'],
        ]);

        $code = Artisan::call('app:dev:inject-calibration-positives', [
            '--days' => 60,
            '--limit' => 10,
            '--seed' => 42,
            '--mutual-like-rate' => 1,
            '--first-message-rate' => 1,
            '--reply24h-rate' => 1,
            '--sustained7d-rate' => 1,
            '--explanation-view-rate' => 1,
        ]);

        $this->assertSame(0, $code);

        $m->refresh();
        $this->assertTrue((bool) $m->like_a);
        $this->assertTrue((bool) $m->like_b);

        $roomId = min($a->id, $b->id).'_'.max($a->id, $b->id);
        $this->assertGreaterThanOrEqual(2, ChatMessage::query()->where('room_id', $roomId)->count());
        $this->assertTrue(
            AppEvent::query()
                ->where('event_name', 'match_explanation_view_calibration')
                ->where('match_id', $m->id)
                ->exists()
        );
    }

    public function test_inject_command_blocked_when_disabled(): void
    {
        config()->set('matching.calibration_injector.enabled', false);

        $code = Artisan::call('app:dev:inject-calibration-positives', [
            '--days' => 30,
            '--limit' => 1,
        ]);

        $this->assertSame(1, $code);
        $this->assertStringContainsString(
            'Calibration injector is disabled',
            Artisan::output()
        );
    }
}
