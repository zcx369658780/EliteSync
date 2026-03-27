<?php

namespace Tests\Feature;

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
}
