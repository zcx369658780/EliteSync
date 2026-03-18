<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthQuestionnaireApiTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_login_questionnaire_flow(): void
    {
        $this->seed();

        $register = $this->postJson('/api/v1/auth/register', [
            'phone' => '13800138000',
            'password' => 'secret123',
            'name' => 'zcxve',
        ])->assertCreated()->json();

        $token = $register['access_token'];

        $questions = $this->getJson('/api/v1/questionnaire/questions', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()
            ->assertJsonPath('total', 20)
            ->assertJsonPath('required', 20)
            ->json();

        $exclude = collect($questions['items'] ?? [])->pluck('id')->all();
        $replace = $this->postJson('/api/v1/questionnaire/questions/replace', [
            'exclude_ids' => $exclude,
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->json();
        $this->assertNotContains((int) $replace['id'], $exclude);

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                ['question_id' => 1, 'answer' => '三观契合'],
                ['question_id' => 2, 'answer' => '咖啡聊天'],
            ],
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk();

        $this->getJson('/api/v1/questionnaire/progress', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->assertJsonPath('answered', 2);

        $this->getJson('/api/v1/questionnaire/profile', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->assertJsonStructure([
            'answered',
            'total',
            'complete',
            'vector',
            'summary' => ['label', 'highlights'],
        ]);

        $login = $this->postJson('/api/v1/auth/login', [
            'phone' => '13800138000',
            'password' => 'secret123',
        ])->assertOk()->json();

        $this->assertNotEmpty($login['access_token']);
    }

    public function test_submit_answers_accepts_v2_payload_fields(): void
    {
        $this->seed();

        $register = $this->postJson('/api/v1/auth/register', [
            'phone' => '13800138111',
            'password' => 'secret123',
            'name' => 'v2-user',
        ])->assertCreated()->json();

        $token = $register['access_token'];
        $questionId = 1;

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                [
                    'question_id' => $questionId,
                    'selected_answer' => ['A'],
                    'acceptable_answers' => ['A', 'B'],
                    'importance' => 3,
                    'version' => 1,
                ],
            ],
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk();

        $this->assertDatabaseHas('questionnaire_answers', [
            'user_id' => $register['user']['id'],
            'questionnaire_question_id' => $questionId,
            'importance' => 3,
            'version' => 1,
        ]);
    }
}
