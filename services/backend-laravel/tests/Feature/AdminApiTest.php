<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Config;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminApiTest extends TestCase
{
    use RefreshDatabase;

    private function fullAnswersPayload(): array
    {
        $ids = QuestionnaireQuestion::query()->where('enabled', true)->orderBy('sort_order')->pluck('id');
        return $ids->map(fn ($id) => ['question_id' => (int) $id, 'answer' => 'A'])->values()->all();
    }

    public function test_verify_queue_and_update_flow(): void
    {
        $admin = User::create([
            'phone' => '13800000101',
            'name' => 'admin',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        $pendingUser = User::create([
            'phone' => '13800000102',
            'name' => 'pending',
            'password' => 'secret123',
            'verify_status' => 'pending',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $this->getJson('/api/v1/admin/verify-queue')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $pendingUser->id);

        $this->postJson('/api/v1/admin/verify/'.$pendingUser->id, [
            'status' => 'approved',
        ])->assertOk()->assertJsonPath('ok', true);

        $this->postJson('/api/v1/admin/users/'.$pendingUser->id.'/disable')
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/admin/users')
            ->assertOk()
            ->assertJsonFragment([
                'id' => $pendingUser->id,
                'verify_status' => 'approved',
                'disabled' => true,
            ]);
    }

    public function test_dev_matching_and_release_drop_flow(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000111',
            'name' => 'admin',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);

        $u1 = User::create([
            'phone' => '13800000112',
            'name' => 'u1',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'female',
        ]);

        User::create([
            'phone' => '13800000113',
            'name' => 'u2',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'female',
        ]);

        $incomplete = User::create([
            'phone' => '13800000114',
            'name' => 'u3',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();
        Sanctum::actingAs($u1);
        $this->postJson('/api/v1/questionnaire/answers', [
            'answers' => $this->fullAnswersPayload(),
        ])->assertOk();
        Sanctum::actingAs($admin);

        $run = $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->json();

        $this->assertGreaterThanOrEqual(1, (int) ($run['pairs'] ?? 0));
        $this->assertSame(2, (int) ($run['eligible_users'] ?? 0));

        $this->postJson('/api/v1/admin/dev/release-drop')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('released', 1);

        Sanctum::actingAs($u1);
        $current = $this->getJson('/api/v1/matches/current')
            ->assertOk()
            ->assertJsonStructure([
                'match_reasons' => [
                    'summary',
                    'match',
                    'mismatch',
                    'confidence',
                    'modules' => [[
                        'key',
                        'label',
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
                        'highlights',
                        'risks',
                        'degraded',
                        'degrade_reason',
                    ]],
                ],
            ])
            ->json();
        $this->assertNotEmpty(data_get($current, 'match_reasons.modules', []));

        Sanctum::actingAs($admin);
        $this->assertFalse(
            DatingMatch::query()
                ->where('user_a', $incomplete->id)
                ->orWhere('user_b', $incomplete->id)
                ->exists()
        );
    }

    public function test_dev_matching_handles_multiple_chunks_without_key_error(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000121',
            'name' => 'admin2',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);

        $u1 = User::create(['phone' => '13800000122', 'name' => 'u1', 'password' => 'secret123', 'verify_status' => 'approved', 'city' => 'Nanyang', 'gender' => 'female']);
        $u2 = User::create(['phone' => '13800000123', 'name' => 'u2', 'password' => 'secret123', 'verify_status' => 'approved', 'city' => 'Nanyang', 'gender' => 'male']);
        $u3 = User::create(['phone' => '13800000124', 'name' => 'u3', 'password' => 'secret123', 'verify_status' => 'approved', 'city' => 'Nanyang', 'gender' => 'female']);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            ...$this->fullAnswersPayload(),
        ]])->assertOk();

        Sanctum::actingAs($u1);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            ...$this->fullAnswersPayload(),
        ]])->assertOk();

        Sanctum::actingAs($u2);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            ...$this->fullAnswersPayload(),
        ]])->assertOk();

        Sanctum::actingAs($u3);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => [
            ...$this->fullAnswersPayload(),
        ]])->assertOk();

        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('pairs', 2);
    }

    public function test_dev_matching_can_toggle_synthetic_user_inclusion(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000126',
            'name' => 'admin-syn',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'is_synthetic' => false,
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);
        $real1 = User::create([
            'phone' => '13800000127',
            'name' => 'real-1',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'is_synthetic' => false,
            'city' => 'Nanyang',
            'gender' => 'female',
        ]);
        $real2 = User::create([
            'phone' => '13800000128',
            'name' => 'real-2',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'is_synthetic' => false,
            'city' => 'Nanyang',
            'gender' => 'male',
        ]);
        $syn = User::create([
            'phone' => '13800000129',
            'name' => 'syn-1',
            'password' => 'secret123',
            'verify_status' => 'approved',
            'is_synthetic' => true,
            'synthetic_batch' => 'test_batch',
            'city' => 'Nanyang',
            'gender' => 'female',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);

        // complete questionnaire for 4 users
        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => $this->fullAnswersPayload()])->assertOk();
        Sanctum::actingAs($real1);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => $this->fullAnswersPayload()])->assertOk();
        Sanctum::actingAs($real2);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => $this->fullAnswersPayload()])->assertOk();
        Sanctum::actingAs($syn);
        $this->postJson('/api/v1/questionnaire/answers', ['answers' => $this->fullAnswersPayload()])->assertOk();

        Sanctum::actingAs($admin);

        $this->postJson('/api/v1/admin/dev/matching-debug', [
            'include_synthetic_users' => false,
        ])->assertOk()->assertJsonPath('include_synthetic_users', false);

        $respOff = $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('include_synthetic_users', false)
            ->json();
        $this->assertSame(3, (int) ($respOff['eligible_users'] ?? 0));

        $this->postJson('/api/v1/admin/dev/matching-debug', [
            'include_synthetic_users' => true,
        ])->assertOk()->assertJsonPath('include_synthetic_users', true);

        $respOn = $this->postJson('/api/v1/admin/dev/run-matching')
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('include_synthetic_users', true)
            ->json();
        $this->assertSame(4, (int) ($respOn['eligible_users'] ?? 0));
    }

    public function test_admin_endpoints_forbid_non_admin_user(): void
    {
        $admin = User::create([
            'phone' => '13800000131',
            'name' => 'admin3',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);
        $normal = User::create([
            'phone' => '13800000132',
            'name' => 'normal',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($normal);

        $this->getJson('/api/v1/admin/users')
            ->assertStatus(403)
            ->assertJsonPath('message', 'admin access required');
    }

    public function test_question_quality_stats_endpoint_returns_reason_breakdown(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000141',
            'name' => 'admin4',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $resp = $this->getJson('/api/v1/admin/questionnaire/quality-stats')
            ->assertOk()
            ->assertJsonStructure([
                'total',
                'by_tier',
                'by_tag',
                'reasons' => [['quality_tier', 'quality_tag', 'quality_reason', 'count']],
                'low_drop_reasons',
            ])
            ->json();

        $this->assertGreaterThan(0, (int) ($resp['total'] ?? 0));
        $this->assertNotEmpty($resp['by_tier'] ?? []);
        $this->assertNotEmpty($resp['by_tag'] ?? []);
        $this->assertNotEmpty($resp['reasons'] ?? []);
    }

    public function test_prune_low_drop_questions_supports_dry_run_and_apply(): void
    {
        $this->seed();

        $admin = User::create([
            'phone' => '13800000151',
            'name' => 'admin5',
            'password' => 'secret123',
            'verify_status' => 'approved',
        ]);

        Config::set('app.admin_phones', [$admin->phone]);
        Sanctum::actingAs($admin);

        $initial = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->where('quality_tag', 'low_drop')
            ->count();
        if ($initial === 0) {
            QuestionnaireQuestion::query()->create([
                'question_key' => 'TEST_LOW_DROP_001',
                'category' => 'values',
                'subtopic' => 'test',
                'recommended_bank' => 'core',
                'quality_tier' => 'normal',
                'quality_tag' => 'low_drop',
                'quality_reason' => 'test_seed',
                'content' => 'test low drop question',
                'question_text_zh' => 'test low drop question',
                'question_text_en' => 'test low drop question',
                'question_type' => 'single_choice',
                'acceptable_answer_logic' => 'single_select',
                'options' => [
                    ['option_id' => 'A', 'label' => ['zh' => 'A', 'en' => 'A'], 'dimension_weights' => [], 'evaluation_standard' => ['code' => 'T', 'zh' => 'T', 'en' => 'T'], 'score' => 1],
                ],
                'sort_order' => 999999,
                'enabled' => true,
                'version' => 1,
            ]);
            $initial = 1;
        }
        $this->assertGreaterThan(0, $initial);

        $dryRun = $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', [
            'dry_run' => true,
        ])->assertOk()->json();

        $this->assertTrue((bool) ($dryRun['ok'] ?? false));
        $this->assertTrue((bool) ($dryRun['dry_run'] ?? false));
        $this->assertSame($initial, (int) ($dryRun['candidates'] ?? -1));
        $this->assertSame(0, (int) ($dryRun['updated'] ?? -1));

        $apply = $this->postJson('/api/v1/admin/questionnaire/prune-low-drop', [
            'dry_run' => false,
        ])->assertOk()->json();

        $this->assertTrue((bool) ($apply['ok'] ?? false));
        $this->assertFalse((bool) ($apply['dry_run'] ?? true));
        $this->assertSame($initial, (int) ($apply['updated'] ?? -1));

        $after = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->where('quality_tag', 'low_drop')
            ->count();
        $this->assertSame(0, $after);
    }
}
