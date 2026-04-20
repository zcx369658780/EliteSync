<?php

namespace Tests\Feature;

use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireAttempt;
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
            'birthday' => '1998-08-15',
            'realname_verified' => true,
        ])->assertCreated()->json();

        $token = $register['access_token'];

        $questions = $this->getJson('/api/v1/questionnaire/questions', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()
            ->assertJsonPath('meta.version', 'q_v2')
            ->assertJsonPath('meta.bank_version', 'qb_v1')
            ->assertJsonPath('meta.attempt_version', 'qa_v1')
            ->assertJsonPath('total', 20)
            ->assertJsonPath('required', 20)
            ->json();
        $this->assertSame('q_v2', $questions['meta']['version']);
        $this->assertSame('qb_v1', $questions['meta']['bank_version']);
        $this->assertSame('qa_v1', $questions['meta']['attempt_version']);
        $this->assertSame('q_v2', $questions['items'][0]['questionnaire_version']);
        $this->assertSame('qb_v1', $questions['items'][0]['bank_version']);

        $exclude = collect($questions['items'] ?? [])->pluck('id')->all();
        $replace = $this->postJson('/api/v1/questionnaire/questions/replace', [
            'exclude_ids' => $exclude,
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->json();
        $this->assertNotContains((int) $replace['id'], $exclude);

        $submit = $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                ['question_id' => 1, 'answer' => '三观契合'],
                ['question_id' => 2, 'answer' => '咖啡聊天'],
            ],
        ], [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->json();
        $this->assertSame('q_v2', $submit['questionnaire_version'] ?? null);
        $this->assertSame('qb_v1', $submit['bank_version'] ?? null);
        $this->assertSame('qa_v1', $submit['attempt_version'] ?? null);
        $this->assertNotEmpty(data_get($submit, 'profile.summary.label'));
        $this->assertNotEmpty(data_get($submit, 'profile.summary.highlights'));

        $answer = QuestionnaireAnswer::query()
            ->where('user_id', $register['user']['id'])
            ->where('questionnaire_question_id', 1)
            ->first();
        $this->assertNotNull($answer);
        $payload = (array) ($answer?->answer_payload ?? []);
        $this->assertSame('q_v2', $payload['questionnaire_version'] ?? null);
        $this->assertSame('qb_v1', $payload['bank_version'] ?? null);
        $this->assertSame('qa_v1', $payload['attempt_version'] ?? null);
        $this->assertNotEmpty($payload['question_key'] ?? null);
        $this->assertGreaterThan(0, (int) ($payload['question_version'] ?? 0));

        $attempt = QuestionnaireAttempt::query()
            ->where('user_id', $register['user']['id'])
            ->latest('id')
            ->first();
        $this->assertNotNull($attempt);
        $this->assertSame('q_v2', $attempt?->questionnaire_version);
        $this->assertSame('qb_v1', $attempt?->bank_version);
        $this->assertSame('qa_v1', $attempt?->attempt_version);

        $history = $this->getJson('/api/v1/questionnaire/history', [
            'Authorization' => 'Bearer '.$token,
        ])->assertOk()->json();
        $this->assertGreaterThanOrEqual(1, (int) ($history['total'] ?? 0));
        $this->assertSame('q_v2', $history['items'][0]['questionnaire_version'] ?? null);
        $this->assertNotEmpty($history['items'][0]['result_label'] ?? null);
        $this->assertNotEmpty($history['items'][0]['result_highlights'] ?? []);

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
            'birthday' => '1999-09-16',
            'realname_verified' => true,
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
