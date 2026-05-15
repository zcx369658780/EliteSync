<?php

namespace Tests\Feature\Api\V2;

use Tests\TestCase;

class LocationContractTest extends TestCase
{
    public function test_v2_location_contract_returns_static_semantics(): void
    {
        $this->getJson('/api/v2/contracts/location')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.status', 'static_contract_only')
            ->assertJsonPath('data.location_types.birth_location.source_type', 'server_canonical_truth')
            ->assertJsonPath('data.location_types.current_location.source_type', 'future_location_context_or_profile_display')
            ->assertJsonPath('data.location_types.date_place.source_type', 'future_user_confirmed_place')
            ->assertJsonPath('data.location_types.buddy_place.source_type', 'future_buddy_request_or_preference')
            ->assertJsonPath('data.rules.static_contract', true)
            ->assertJsonPath('data.rules.reads_profile_basic', false)
            ->assertJsonPath('data.rules.reads_user_astro_profiles', false)
            ->assertJsonPath('data.rules.writes_profile_basic', false)
            ->assertJsonPath('data.rules.writes_user_astro_profiles', false)
            ->assertJsonPath('data.rules.uses_map_sdk', false)
            ->assertJsonPath('data.rules.requests_real_time_location_permission', false);
    }

    public function test_v2_location_contract_keeps_sensitive_fields_only_in_forbidden_lists(): void
    {
        $payload = $this->getJson('/api/v2/contracts/location')
            ->assertOk()
            ->json('data');

        $locationTypes = $payload['location_types'] ?? [];
        $this->assertArrayHasKey('birth_location', $locationTypes);
        $this->assertArrayHasKey('current_location', $locationTypes);
        $this->assertArrayHasKey('date_place', $locationTypes);
        $this->assertArrayHasKey('buddy_place', $locationTypes);

        $forbidden = [
            'lat',
            'lng',
            'birth_lat',
            'birth_lng',
            'position_signature',
            'location_source',
            'location_shift_minutes',
            'longitude_offset_minutes',
            'equation_of_time_minutes',
            'engine',
            'debug',
            'hash',
            'signature',
            'full_birth_time',
            'phone',
            'exact_address',
            'real_time_location',
            'user_id',
            'profile_id',
        ];

        foreach ($locationTypes as $contract) {
            foreach ($forbidden as $field) {
                $this->assertArrayNotHasKey($field, $contract);
            }
        }

        $this->assertContains('birth_lat', $locationTypes['birth_location']['forbidden_user_visible_fields']);
        $this->assertContains('birth_lng', $locationTypes['birth_location']['forbidden_user_visible_fields']);
        $this->assertContains('position_signature', $locationTypes['birth_location']['forbidden_user_visible_fields']);
        $this->assertContains('location_source', $locationTypes['birth_location']['forbidden_user_visible_fields']);
        $this->assertContains('real_time_location', $locationTypes['current_location']['forbidden_user_visible_fields']);
    }
}
