<?php

namespace Tests\Feature;

use App\Models\AppEvent;
use App\Models\DatingMatch;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MatchApiTest extends TestCase
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

    public function test_current_match_and_confirm_mutual_flow(): void
    {
        $this->seed();

        $userA = User::create([
            'phone' => '13800000001',
            'name' => 'A',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000002',
            'name' => 'B',
            'password' => 'secret123',
        ]);

        $match = DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'highlights' => '你们都喜欢慢节奏聊天',
            'drop_released' => true,
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
        $this->getJson('/api/v1/matches/current')
            ->assertOk()
            ->assertJsonPath('match_id', $match->id)
            ->assertJsonPath('partner_id', $userB->id)
            ->assertJsonPath('partner_nickname', 'B');
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_exposed',
            'actor_user_id' => $userA->id,
            'target_user_id' => $userB->id,
            'match_id' => $match->id,
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/matches/confirm', [
            'match_id' => $match->id,
            'like' => true,
        ])->assertOk()->assertJsonPath('mutual', false);
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_confirm',
            'actor_user_id' => $userA->id,
            'target_user_id' => $userB->id,
            'match_id' => $match->id,
        ]);

        Sanctum::actingAs($userB);
        $this->postJson('/api/v1/matches/confirm', [
            'match_id' => $match->id,
            'like' => true,
        ])->assertOk()->assertJsonPath('mutual', true);

        $match->refresh();
        $this->assertTrue((bool) $match->like_a);
        $this->assertTrue((bool) $match->like_b);

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/matches/history')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.partner_nickname', 'B');
    }

    public function test_current_match_returns_404_when_questionnaire_incomplete(): void
    {
        $this->seed();

        $user = User::create([
            'phone' => '13800000003',
            'name' => 'C',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);
        $this->getJson('/api/v1/matches/current')
            ->assertStatus(404)
            ->assertJsonPath('message', 'questionnaire incomplete');
    }

    public function test_current_match_returns_404_when_no_match_after_questionnaire_complete(): void
    {
        $this->seed();

        $user = User::create([
            'phone' => '13800000004',
            'name' => 'D',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($user);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();

        $this->getJson('/api/v1/matches/current')
            ->assertStatus(404)
            ->assertJsonPath('message', 'no match');
    }

    public function test_explanation_by_target_returns_latest_match_payload(): void
    {
        $this->seed();

        $userA = User::create([
            'phone' => '13800000011',
            'name' => 'A2',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000012',
            'name' => 'B2',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => '2026-W10',
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'score_base' => 61,
            'score_final' => 64,
            'score_fair' => 66,
            'highlights' => 'old',
            'drop_released' => true,
            'match_reasons' => [
                'summary' => 'old summary',
                'modules' => [
                    [
                        'key' => 'bazi',
                        'score' => 60,
                        'reason_short' => 'old',
                        'reason_detail' => 'old',
                        'evidence_tags' => ['bazi_unknown'],
                    ],
                ],
            ],
        ]);

        $latest = DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'score_base' => 78,
            'score_final' => 82,
            'score_fair' => 84,
            'highlights' => 'latest highlights',
            'drop_released' => true,
            'match_reasons' => [
                'summary' => 'latest summary',
                'display_score' => 82,
                'rank_score' => 84,
                'modules' => [
                    [
                        'key' => 'zodiac',
                        'score' => 86,
                        'reason_short' => '属相协同',
                        'reason_detail' => '属相六合',
                        'evidence_tags' => ['zodiac_liuhe'],
                    ],
                ],
            ],
        ]);

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/matches/'.$userB->id.'/explanation')
            ->assertOk()
            ->assertJsonPath('match_id', $latest->id)
            ->assertJsonPath('partner_id', $userB->id)
            ->assertJsonPath('partner_nickname', 'B2')
            ->assertJsonPath('highlights', 'latest highlights')
            ->assertJsonPath('match_reasons.summary', 'latest summary')
            ->assertJsonPath('match_reasons.modules.0.evidence_tag_labels.0', '属相六合')
            ->assertJsonPath('match_reasons.module_explanations.0.risk_level', 'low')
            ->assertJsonPath('match_reasons.module_explanations.0.core_tags.0', '属相六合')
            ->assertJsonPath('match_reasons.module_explanations.0.core_tag_explains.属相六合', '属相关系为六合')
            ->assertJsonPath('match_reasons.module_explanations.0.core_tag_refs.属相六合', '十二生肖六合配对传统规则（工程化映射）')
            ->assertJsonPath('match_reasons.module_explanations.0.confidence', 0.5)
            ->assertJsonPath('match_reasons.module_explanations.0.degraded', false)
            ->assertJsonPath('match_reasons.module_explanations.0.priority', 148)
            ->assertJsonPath('match_reasons.module_explanations.0.priority_level', 'normal')
            ->assertJsonPath('match_reasons.module_explanations.0.priority_reason', '置信度偏低')
            ->assertJsonPath('match_reasons.module_explanations.0.evidence_strength', 'low')
            ->assertJsonPath('match_reasons.module_explanations.0.priority_rank', 1)
            ->assertJsonPath('match_reasons.evidence_strength_summary.total', 1)
            ->assertJsonPath('match_reasons.evidence_strength_summary.low', 1)
            ->assertJsonPath('match_reasons.evidence_strength_summary.weak_modules.0.label', 'zodiac')
            ->assertJsonPath('display_score', 82)
            ->assertJsonPath('rank_score', 84);

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/match/'.$userB->id.'/explanation')
            ->assertOk()
            ->assertJsonPath('match_id', $latest->id);
        $this->assertDatabaseHas('app_events', [
            'event_name' => 'match_explanation_view',
            'actor_user_id' => $userA->id,
            'target_user_id' => $userB->id,
            'match_id' => $latest->id,
        ]);
    }

    public function test_explanation_by_target_returns_404_when_not_matched(): void
    {
        $this->seed();
        $userA = User::create([
            'phone' => '13800000013',
            'name' => 'A3',
            'password' => 'secret123',
        ]);
        $userB = User::create([
            'phone' => '13800000014',
            'name' => 'B3',
            'password' => 'secret123',
        ]);

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/matches/'.$userB->id.'/explanation')
            ->assertStatus(404)
            ->assertJsonPath('message', 'no match');
    }

    public function test_explanation_by_target_sorts_module_explanations_by_priority_desc(): void
    {
        $this->seed();

        $userA = User::create([
            'phone' => '13800000015',
            'name' => 'A4',
            'password' => 'secret123',
        ]);
        $userB = User::create([
            'phone' => '13800000016',
            'name' => 'B4',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'score_base' => 70,
            'score_final' => 72,
            'score_fair' => 74,
            'highlights' => 'priority sort',
            'drop_released' => true,
            'match_reasons' => [
                'summary' => 'priority sort summary',
                'modules' => [
                    [
                        'key' => 'zodiac',
                        'label' => '属相匹配',
                        'score' => 88,
                        'confidence' => 0.95,
                        'reason_short' => '高分稳定',
                        'risk_short' => '',
                        'evidence_tags' => ['zodiac_liuhe'],
                    ],
                    [
                        'key' => 'bazi',
                        'label' => '八字匹配',
                        'score' => 55,
                        'confidence' => 0.40,
                        'reason_short' => '分数偏低',
                        'risk_short' => '存在冲突项',
                        'degraded' => true,
                        'degrade_reason' => 'missing_wu_xing',
                        'evidence_tags' => ['bazi_branch_chong'],
                    ],
                    [
                        'key' => 'constellation',
                        'label' => '星座匹配',
                        'score' => 68,
                        'confidence' => 0.55,
                        'reason_short' => '中等',
                        'risk_short' => '需要磨合',
                        'evidence_tags' => ['element_tension'],
                    ],
                ],
            ],
        ]);

        Sanctum::actingAs($userA);
        $json = $this->getJson('/api/v1/matches/'.$userB->id.'/explanation')
            ->assertOk()
            ->json();

        $rows = (array) data_get($json, 'match_reasons.module_explanations', []);
        $this->assertGreaterThanOrEqual(3, count($rows));

        $p0 = (int) data_get($rows, '0.priority', 0);
        $p1 = (int) data_get($rows, '1.priority', 0);
        $p2 = (int) data_get($rows, '2.priority', 0);
        $this->assertTrue($p0 >= $p1 && $p1 >= $p2, 'module_explanations should be sorted by priority desc');
    }
}
