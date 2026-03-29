<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MbtiApiVersioningTest extends TestCase
{
    use RefreshDatabase;

    public function test_quiz_default_and_lite5_versions(): void
    {
        $this->seed();
        $user = User::create([
            'phone' => '13800000931',
            'name' => 'mbti-user',
            'password' => 'secret123',
        ]);
        Sanctum::actingAs($user);

        $this->getJson('/api/v1/profile/mbti/quiz')
            ->assertOk()
            ->assertJsonPath('version_code', 'lite3_v1')
            ->assertJsonPath('total', 3);

        $this->getJson('/api/v1/profile/mbti/quiz?version=lite5_v1')
            ->assertOk()
            ->assertJsonPath('version_code', 'lite5_v1')
            ->assertJsonPath('total', 5)
            ->assertJsonStructure(['available_versions']);
    }

    public function test_submit_lite5_persists_result(): void
    {
        $this->seed();
        $user = User::create([
            'phone' => '13800000932',
            'name' => 'mbti-user-2',
            'password' => 'secret123',
        ]);
        Sanctum::actingAs($user);

        $payload = [
            'version_code' => 'lite5_v1',
            'answers' => [
                ['question_id' => 1, 'option' => 'A'],
                ['question_id' => 2, 'option' => 'B'],
                ['question_id' => 3, 'option' => 'A'],
                ['question_id' => 4, 'option' => 'B'],
                ['question_id' => 5, 'option' => 'A'],
            ],
        ];
        $this->postJson('/api/v1/profile/mbti/submit', $payload)
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonStructure(['result', 'letters', 'scores', 'confidence']);
    }
}

