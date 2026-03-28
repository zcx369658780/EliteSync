<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class HomeContentApiTest extends TestCase
{
    use RefreshDatabase;

    private function actingUser(): User
    {
        $user = User::create([
            'phone' => '13900000001',
            'name' => 'HomeTester',
            'password' => 'secret123',
            'city' => '南阳',
        ]);
        Sanctum::actingAs($user);

        return $user;
    }

    public function test_home_endpoints_return_data_with_expected_shape(): void
    {
        $this->actingUser();

        $this->getJson('/api/v1/home/banner')
            ->assertOk()
            ->assertJsonStructure([
                'data' => ['title', 'subtitle', 'cta'],
            ]);

        $this->getJson('/api/v1/home/shortcuts')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['key', 'title', 'action', 'target']],
            ]);

        $this->getJson('/api/v1/home/feed?tab=recommend&limit=3')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'title', 'summary', 'author', 'likes', 'tags', 'media', 'body']],
                'meta' => ['next_cursor', 'has_more'],
            ]);
    }

    public function test_discover_and_content_detail_endpoints_return_data(): void
    {
        $this->actingUser();

        $discover = $this->getJson('/api/v1/discover/feed?tab=hot&limit=2')
            ->assertOk()
            ->assertJsonStructure([
                'data' => [['id', 'title', 'summary', 'author', 'likes']],
                'meta' => ['next_cursor', 'has_more'],
            ])
            ->json();

        $firstId = $discover['data'][0]['id'] ?? 'discover-101';

        $this->getJson('/api/v1/content/'.$firstId)
            ->assertOk()
            ->assertJsonStructure([
                'data' => ['id', 'title', 'summary', 'author', 'likes', 'tags', 'media', 'body'],
            ]);
    }
}

