<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MatchPayloadContractTest extends TestCase
{
    use RefreshDatabase;

    private function fullAnswersPayload(): array
    {
        $ids = QuestionnaireQuestion::query()->where('enabled', true)->orderBy('sort_order')->pluck('id');
        return $ids->map(fn ($id) => ['question_id' => (int) $id, 'answer' => 'A'])->values()->all();
    }

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function test_current_match_payload_contains_contract_fields_and_module_algo_version(): void
    {
        $this->seed();

        $userA = User::create([
            'phone' => '13800000901',
            'name' => 'ContractA',
            'password' => 'secret123',
        ]);
        $userB = User::create([
            'phone' => '13800000902',
            'name' => 'ContractB',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'highlights' => 'contract test',
            'drop_released' => true,
            'match_reasons' => [
                'summary' => 'test summary',
                'match' => ['a'],
                'mismatch' => ['b'],
                'confidence' => 0.66,
                'modules' => [[
                    'key' => 'mbti',
                    'label' => 'MBTI 匹配',
                    'score' => 70,
                    'weight' => 0.15,
                    'confidence' => 0.62,
                    'verdict' => 'medium',
                    'reason_short' => 'short',
                    'reason_detail' => 'detail',
                    'risk_short' => 'risk',
                    'risk_detail' => 'risk detail',
                    'evidence_tags' => ['t1'],
                    'evidence' => ['k' => 'v'],
                    'degraded' => false,
                    'degrade_reason' => '',
                ]],
            ],
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();
        Sanctum::actingAs($userB);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();

        Sanctum::actingAs($userA);
        $json = $this->getJson('/api/v1/matches/current')
            ->assertOk()
            ->assertJsonStructure([
                'match_reasons' => [
                    'contract_version',
                    'generated_at',
                    'summary',
                    'match',
                    'mismatch',
                    'confidence',
                    'reason_glossary',
                    'modules' => [[
                        'key',
                        'label',
                        'algo_version',
                        'score',
                        'weight',
                        'confidence',
                        'verdict',
                        'reason_short',
                        'reason_detail',
                        'risk_short',
                        'risk_detail',
                        'evidence_tags',
                        'evidence',
                        'degraded',
                        'degrade_reason',
                    ]],
                ],
            ])
            ->json();

        $reasons = (array) ($json['match_reasons'] ?? []);
        $this->assertIsString($reasons['contract_version'] ?? null);
        $this->assertNotSame('', (string) ($reasons['contract_version'] ?? ''));
        $this->assertIsString($reasons['generated_at'] ?? null);
        $this->assertNotSame('', (string) ($reasons['generated_at'] ?? ''));
        $this->assertIsArray($reasons['reason_glossary'] ?? null);

        $module = (array) (($reasons['modules'][0] ?? []) ?: []);
        $this->assertIsString($module['algo_version'] ?? null);
        $this->assertNotSame('', (string) ($module['algo_version'] ?? ''));
        $this->assertIsArray($module['evidence_tags'] ?? null);
        $this->assertIsArray($module['evidence'] ?? null);
    }
}
