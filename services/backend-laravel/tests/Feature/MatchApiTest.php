<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MatchApiTest extends TestCase
{
    use RefreshDatabase;

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
            'answers' => [
                ['question_id' => 1, 'answer' => 'A'],
                ['question_id' => 2, 'answer' => 'B'],
                ['question_id' => 3, 'answer' => 'A'],
            ],
        ])->assertOk();
        Sanctum::actingAs($userB);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => [
                ['question_id' => 1, 'answer' => 'A'],
                ['question_id' => 2, 'answer' => 'B'],
                ['question_id' => 3, 'answer' => 'A'],
            ],
        ])->assertOk();

        Sanctum::actingAs($userA);
        $this->getJson('/api/v1/matches/current')
            ->assertOk()
            ->assertJsonPath('match_id', $match->id)
            ->assertJsonPath('partner_id', $userB->id);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/matches/confirm', [
            'match_id' => $match->id,
            'like' => true,
        ])->assertOk()->assertJsonPath('mutual', false);

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
            ->assertJsonPath('total', 1);
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
}
