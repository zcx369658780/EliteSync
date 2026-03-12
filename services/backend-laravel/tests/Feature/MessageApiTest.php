<?php

namespace Tests\Feature;

use App\Models\DatingMatch;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class MessageApiTest extends TestCase
{
    use RefreshDatabase;

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function test_send_list_and_mark_read_message_flow(): void
    {
        $userA = User::create([
            'phone' => '13800000011',
            'name' => 'A',
            'password' => 'secret123',
        ]);

        $userB = User::create([
            'phone' => '13800000012',
            'name' => 'B',
            'password' => 'secret123',
        ]);

        DatingMatch::create([
            'week_tag' => $this->weekTag(),
            'user_a' => $userA->id,
            'user_b' => $userB->id,
            'drop_released' => true,
        ]);

        Sanctum::actingAs($userA);
        $send = $this->postJson('/api/v1/messages', [
            'receiver_id' => $userB->id,
            'content' => 'hello',
        ])->assertOk()->assertJsonPath('ok', true)->json();

        $messageId = $send['id'];

        Sanctum::actingAs($userB);
        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('total', 1)
            ->assertJsonPath('items.0.id', $messageId)
            ->assertJsonPath('items.0.content', 'hello');

        $this->postJson('/api/v1/messages/read/'.$messageId)
            ->assertOk()
            ->assertJsonPath('ok', true);

        $this->getJson('/api/v1/messages?peer_id='.$userA->id)
            ->assertOk()
            ->assertJsonPath('items.0.is_read', true);
    }
}
