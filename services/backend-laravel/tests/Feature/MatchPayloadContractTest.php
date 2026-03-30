<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
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
                'display_score' => 71,
                'rank_score' => 69,
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
                'display_score',
                'rank_score',
                'module_explanations',
                'explanation_blocks',
                'compatibility_sections',
                'evidence_strength_summary',
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
        $this->assertIsArray($reasons['module_explanations'] ?? null);
        $this->assertIsArray($reasons['explanation_blocks'] ?? null);
        $this->assertIsArray($reasons['compatibility_sections'] ?? null);
        $this->assertIsArray($reasons['evidence_strength_summary'] ?? null);
        $this->assertIsInt($reasons['display_score'] ?? null);
        $this->assertIsInt($reasons['rank_score'] ?? null);

        $module = (array) (($reasons['modules'][0] ?? []) ?: []);
        $this->assertIsString($module['algo_version'] ?? null);
        $this->assertNotSame('', (string) ($module['algo_version'] ?? ''));
        $this->assertIsArray($module['evidence_tags'] ?? null);
        $this->assertIsArray($module['evidence'] ?? null);
    }

    public function test_current_match_payload_contains_all_module_contracts_from_matching_engine(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000911',
            'name' => 'contract-admin',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);
        $a = User::create([
            'phone' => '13800000912',
            'name' => 'contract-u1',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'female',
            'public_mbti' => 'INFP',
            'public_zodiac_sign' => '巨蟹座',
            'zodiac_animal' => '马',
            'private_bazi' => '甲子年 丙寅月 丁卯日 庚午时',
            'private_natal_chart' => [
                'moon_sign' => '双鱼座',
                'asc_sign' => '天秤座',
                'wu_xing' => ['木' => 2, '火' => 3, '土' => 2, '金' => 1, '水' => 2],
            ],
        ]);
        $b = User::create([
            'phone' => '13800000913',
            'name' => 'contract-u2',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'male',
            'public_mbti' => 'ENFJ',
            'public_zodiac_sign' => '天蝎座',
            'zodiac_animal' => '龙',
            'private_bazi' => '乙丑年 丁卯月 己巳日 壬申时',
            'private_natal_chart' => [
                'moon_sign' => '巨蟹座',
                'asc_sign' => '白羊座',
                'wu_xing' => ['木' => 1, '火' => 3, '土' => 3, '金' => 2, '水' => 1],
            ],
        ]);

        Config::set('app.admin_phones', [$admin->phone]);

        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();
        Sanctum::actingAs($a);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();
        Sanctum::actingAs($b);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();

        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true);
        $this->postJson('/api/v1/admin/dev/release-drop')
            ->assertOk()
            ->assertJsonPath('ok', true);

        Sanctum::actingAs($a);
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
                    'display_score',
                    'rank_score',
                    'module_explanations',
                    'explanation_blocks',
                    'compatibility_sections',
                    'evidence_strength_summary',
                    'reason_glossary',
                    'modules',
                ],
            ])
            ->json();

        $modules = (array) data_get($json, 'match_reasons.modules', []);
        $moduleExplanations = (array) data_get($json, 'match_reasons.module_explanations', []);
        $explanationBlocks = (array) data_get($json, 'match_reasons.explanation_blocks', []);
        $this->assertNotEmpty($modules, 'match_reasons.modules should not be empty');
        $this->assertNotEmpty($moduleExplanations, 'match_reasons.module_explanations should not be empty');
        $this->assertNotEmpty($explanationBlocks, 'match_reasons.explanation_blocks should not be empty');
        $this->assertArrayHasKey('label', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('score', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('confidence_tier', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('reason', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('risk', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('risk_level', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('confidence', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('degraded', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('degrade_reason', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('engine_source', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('engine_mode', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('data_quality', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('precision_level', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('confidence_reason', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('display_guard', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('priority', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('priority_level', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('priority_reason', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('evidence_strength', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('evidence_strength_reason', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('priority_rank', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('tags', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('core_tags', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('aux_tags', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('core_tag_explains', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('aux_tag_explains', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('core_tag_refs', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('aux_tag_refs', (array) ($moduleExplanations[0] ?? []));
        $this->assertArrayHasKey('summary', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('process', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('risks', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('advice', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('core_evidence', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('supporting_evidence', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('confidence', (array) ($explanationBlocks[0] ?? []));
        $this->assertArrayHasKey('priority', (array) ($explanationBlocks[0] ?? []));
        $sections = (array) data_get($json, 'match_reasons.compatibility_sections', []);
        $this->assertArrayHasKey('natal_compatibility', $sections);
        $this->assertArrayHasKey('synastry', $sections);
        $this->assertArrayHasKey('composite_like', $sections);
        $summary = (array) data_get($json, 'match_reasons.evidence_strength_summary', []);
        $this->assertArrayHasKey('high', $summary);
        $this->assertArrayHasKey('medium', $summary);
        $this->assertArrayHasKey('low', $summary);
        $this->assertArrayHasKey('total', $summary);
        $this->assertArrayHasKey('weak_modules', $summary);
        $this->assertIsArray($summary['weak_modules']);
        $firstWeak = (array) (($summary['weak_modules'][0] ?? []) ?: []);
        if (!empty($firstWeak)) {
            $this->assertArrayHasKey('label', $firstWeak);
            $this->assertArrayHasKey('reason', $firstWeak);
            $this->assertArrayHasKey('priority_rank', $firstWeak);
        }

        $byKey = [];
        foreach ($modules as $m) {
            $key = (string) data_get($m, 'key', '');
            if ($key !== '') {
                $byKey[$key] = $m;
            }
        }

        $expected = ['personality', 'mbti', 'bazi', 'zodiac', 'constellation', 'natal_chart', 'pair_chart'];
        foreach ($expected as $k) {
            $this->assertArrayHasKey($k, $byKey, "module {$k} missing");
            $row = (array) $byKey[$k];
            foreach ([
                'key', 'label', 'algo_version', 'score', 'weight', 'confidence', 'verdict',
                'reason_short', 'reason_detail', 'risk_short', 'risk_detail',
                'evidence_tags', 'evidence_tag_labels', 'display_tags', 'evidence', 'highlights', 'risks', 'degraded', 'degrade_reason',
                'engine_source', 'engine_mode', 'data_quality', 'precision_level', 'confidence_tier', 'confidence_reason', 'display_guard',
            ] as $field) {
                $this->assertArrayHasKey($field, $row, "module {$k} field {$field} missing");
            }
            $this->assertIsArray($row['evidence_tags']);
            $this->assertIsArray($row['evidence_tag_labels']);
            $this->assertIsArray($row['evidence']);
            $this->assertIsArray($row['highlights']);
            $this->assertIsArray($row['risks']);
            $this->assertIsArray($row['display_tags']);
            $this->assertIsArray($row['confidence_reason']);
            $this->assertIsArray($row['display_guard']);
            $this->assertIsBool((bool) $row['degraded']);
        }
    }
}
