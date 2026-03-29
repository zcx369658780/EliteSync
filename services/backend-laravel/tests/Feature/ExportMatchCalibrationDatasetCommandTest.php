<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Artisan;
use Tests\TestCase;

class ExportMatchCalibrationDatasetCommandTest extends TestCase
{
    use RefreshDatabase;

    public function test_export_match_calibration_dataset_generates_json_and_csv(): void
    {
        $this->seed();

        $a = User::create([
            'phone' => '13800007991',
            'name' => 'cal-a',
            'password' => 'secret123',
        ]);
        $b = User::create([
            'phone' => '13800007992',
            'name' => 'cal-b',
            'password' => 'secret123',
        ]);

        $match = DatingMatch::create([
            'week_tag' => now()->utc()->format('Y-\WW'),
            'user_a' => $a->id,
            'user_b' => $b->id,
            'drop_released' => true,
            'like_a' => true,
            'like_b' => false,
            'score_final' => 75,
            'score_fair' => 77,
            'score_personality_total' => 70,
            'score_mbti_total' => 68,
            'score_astro_total' => 80,
            'score_bazi' => 82,
            'score_zodiac' => 76,
            'score_constellation' => 72,
            'score_natal_chart' => 74,
            'match_reasons' => [
                'confidence' => 0.73,
                'display_score' => 75,
                'rank_score' => 77,
                'modules' => [
                    ['key' => 'personality', 'score' => 70, 'confidence' => 0.8, 'degraded' => false, 'weight' => 0.2, 'verdict' => 'medium'],
                    ['key' => 'mbti', 'score' => 68, 'confidence' => 0.6, 'degraded' => false, 'weight' => 0.15, 'verdict' => 'medium'],
                    ['key' => 'bazi', 'score' => 82, 'confidence' => 0.85, 'degraded' => false, 'weight' => 0.32, 'verdict' => 'strong'],
                    ['key' => 'zodiac', 'score' => 76, 'confidence' => 1.0, 'degraded' => false, 'weight' => 0.18, 'verdict' => 'strong'],
                    ['key' => 'constellation', 'score' => 72, 'confidence' => 0.9, 'degraded' => false, 'weight' => 0.08, 'verdict' => 'medium'],
                    ['key' => 'natal_chart', 'score' => 74, 'confidence' => 0.7, 'degraded' => false, 'weight' => 0.07, 'verdict' => 'medium'],
                    ['key' => 'pair_chart', 'score' => 71, 'confidence' => 0.65, 'degraded' => false, 'weight' => 0.1, 'verdict' => 'medium'],
                ],
            ],
        ]);

        ChatMessage::create([
            'room_id' => min($a->id, $b->id).'_'.max($a->id, $b->id),
            'sender_id' => $a->id,
            'receiver_id' => $b->id,
            'content' => 'hello',
        ]);

        AppEvent::create([
            'event_name' => 'match_explanation_view',
            'actor_user_id' => $a->id,
            'target_user_id' => $b->id,
            'match_id' => $match->id,
            'payload' => ['from' => 'test'],
        ]);

        $jsonPath = 'docs/devlogs/MATCH_CALIBRATION_DATASET_TEST.json';
        $csvPath = 'docs/devlogs/MATCH_CALIBRATION_DATASET_TEST.csv';
        @unlink(base_path($jsonPath));
        @unlink(base_path($csvPath));

        $code = Artisan::call('app:dev:export-match-calibration', [
            '--days' => 60,
            '--out-json' => $jsonPath,
            '--out-csv' => $csvPath,
        ]);

        $this->assertSame(0, $code);
        $this->assertFileExists(base_path($jsonPath));
        $this->assertFileExists(base_path($csvPath));

        $json = json_decode((string) file_get_contents(base_path($jsonPath)), true);
        $this->assertIsArray($json);
        $this->assertSame(1, (int) ($json['count'] ?? 0));
        $this->assertIsArray($json['columns'] ?? null);
        $this->assertNotEmpty($json['rows'] ?? []);
        $first = (array) (($json['rows'][0] ?? []) ?: []);
        $this->assertArrayHasKey('match_id', $first);
        $this->assertArrayHasKey('label_positive_reply24h', $first);
        $this->assertArrayHasKey('m_bazi_score', $first);
    }
}

