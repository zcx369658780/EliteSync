<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MbtiApiVersioningTest extends TestCase
{
    use RefreshDatabase;

    public function test_quiz_and_submit_are_disabled_when_feature_is_off(): void
    {
        $this->seed();
        $user = User::create([
            'phone' => '13800000931',
            'name' => 'mbti-user',
            'password' => 'secret123',
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/mbti/quiz')
            ->assertStatus(410)
            ->assertJsonPath('message', 'feature_disabled')
            ->assertJsonPath('feature', 'mbti')
            ->assertJsonPath('available', false);

        $this->postJson('/api/v1/profile/mbti/submit', [
            'version_code' => 'lite5_v1',
            'answers' => [
                ['question_id' => 1, 'option' => 'A'],
            ],
        ])->assertStatus(410)
            ->assertJsonPath('message', 'feature_disabled')
            ->assertJsonPath('feature', 'mbti')
            ->assertJsonPath('available', false);
    }
}
