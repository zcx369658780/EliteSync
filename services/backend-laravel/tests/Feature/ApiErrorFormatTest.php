<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiErrorFormatTest extends TestCase
{
    use RefreshDatabase;

    public function test_unauthenticated_api_returns_unified_error_payload(): void
    {
        $this->getJson('/api/v1/questionnaire/questions')
            ->assertStatus(401)
            ->assertJsonPath('ok', false)
            ->assertJsonPath('error.code', 'unauthenticated')
            ->assertJsonPath('error.message', 'Unauthenticated.');
    }
}

