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

        $this->getJson('/api/v1/questionnaire/questions', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->assertJsonPath('total', 3);

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

        $login = $this->postJson('/api/v1/auth/login', [
            'phone' => '13800138000',
            'password' => 'secret123',
        ])->assertOk()->json();

        $this->assertNotEmpty($login['access_token']);
    }
}
