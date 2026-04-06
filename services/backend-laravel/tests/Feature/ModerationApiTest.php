<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\ModerationReport;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class ModerationApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function test_report_block_and_appeal_flow(): void
    {
        $reporter = User::create([
            'phone' => '13800003001',
            'name' => 'Reporter',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $target = User::create([
            'phone' => '13800003002',
            'name' => 'Target',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        Sanctum::actingAs($reporter);

        $report = $this->postJson('/api/v1/moderation/reports', [
            'target_user_id' => $target->id,
            'category' => 'user',
            'reason_code' => 'harassment',
            'detail' => 'test report',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true)
            ->assertJsonPath('report.status', 'new')
            ->json('report');

        $this->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $target->id,
            'reason_code' => 'chat_menu',
        ])
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/moderation/blocks')
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.blocked_user_id', $target->id);

        $reportId = (int) $report['id'];
        $this->postJson("/api/v1/moderation/reports/{$reportId}/appeal", [
            'appeal_note' => 'please review',
        ])
            ->assertOk()
            ->assertJsonPath('report.appeal_status', 'submitted');

        $this->assertDatabaseHas('moderation_reports', [
            'id' => $reportId,
            'appeal_status' => 'submitted',
        ]);
    }

    public function test_block_prevents_chat_send(): void
    {
        $userA = User::create([
            'phone' => '13800003003',
            'name' => 'A',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $userB = User::create([
            'phone' => '13800003004',
            'name' => 'B',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $this->postJson('/api/v1/moderation/blocks', [
            'blocked_user_id' => $userB->id,
            'reason_code' => 'chat_menu',
        ])->assertOk();

        $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'hello',
        ])->assertStatus(403)
            ->assertJsonPath('message', 'chat blocked by moderation');
    }

    public function test_admin_report_action_updates_user_status(): void
    {
        config(['app.admin_phones' => ['18000000000']]);

        $admin = User::create([
            'phone' => '18000000000',
            'name' => 'Admin',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $reporter = User::create([
            'phone' => '13800003005',
            'name' => 'Reporter2',
            'password' => 'secret123',
            'gender' => 'male',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);
        $target = User::create([
            'phone' => '13800003006',
            'name' => 'Target2',
            'password' => 'secret123',
            'gender' => 'female',
            'city' => '南阳',
            'relationship_goal' => 'dating',
        ]);

        $report = ModerationReport::create([
            'reporter_id' => $reporter->id,
            'target_user_id' => $target->id,
            'category' => 'user',
            'reason_code' => 'spam',
            'status' => 'new',
        ]);

        Sanctum::actingAs($admin);
        $this->postJson('/api/v1/admin/reports/'.$report->id.'/action', [
            'action' => 'banned',
            'note' => 'confirmed spam',
        ])->assertOk()
            ->assertJsonPath('report.status', 'action_taken');

        $this->assertDatabaseHas('users', [
            'id' => $target->id,
            'disabled' => true,
            'moderation_status' => 'banned',
        ]);
    }
}
