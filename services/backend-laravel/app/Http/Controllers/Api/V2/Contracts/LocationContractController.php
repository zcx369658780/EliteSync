<?php

namespace App\Http\Controllers\Api\V2\Contracts;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;

class LocationContractController extends Controller
{
    public function __invoke(): JsonResponse
    {
        return response()->json([
            'success' => true,
            'data' => [
                'status' => 'static_contract_only',
                'contract_version' => '6.0-A1-narrow-v2-location-contract',
                'description' => 'Static location semantics only; no profile/basic read, no user_astro_profiles read, no writeback, no map SDK, and no real-time location permission request.',
                'location_types' => [
                    'birth_location' => [
                        'purpose' => 'astro, bazi, and ziwei canonical truth display boundary',
                        'source_type' => 'server_canonical_truth',
                        'display_precision' => 'province_city_or_district_name',
                        'allowed_internal_use' => [
                            'astro_calculation',
                            'profile_truth_display_boundary',
                        ],
                        'user_visible_precision' => 'administrative_name_only',
                        'forbidden_user_visible_fields' => [
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
                        ],
                        'writeback_rule' => 'this static contract endpoint never writes profile/basic or user_astro_profiles',
                    ],
                    'current_location' => [
                        'purpose' => 'living area, match range, and alpha distribution boundary',
                        'source_type' => 'future_location_context_or_profile_display',
                        'display_precision' => 'city_district_or_business_area',
                        'allowed_internal_use' => [
                            'match_range',
                            'distribution_analysis',
                        ],
                        'user_visible_precision' => 'city_or_business_area',
                        'forbidden_user_visible_fields' => [
                            'lat',
                            'lng',
                            'exact_address',
                            'real_time_location',
                            'user_id',
                            'profile_id',
                        ],
                        'writeback_rule' => 'must not overwrite birth_location or astro truth',
                    ],
                    'date_place' => [
                        'purpose' => 'future Date Drop meeting suggestion boundary',
                        'source_type' => 'future_user_confirmed_place',
                        'display_precision' => 'city_business_area_or_place_name',
                        'allowed_internal_use' => [
                            'date_drop_future_contract',
                        ],
                        'user_visible_precision' => 'city_business_area_or_user_confirmed_place',
                        'forbidden_user_visible_fields' => [
                            'lat',
                            'lng',
                            'exact_address',
                            'real_time_location',
                            'user_id',
                            'profile_id',
                        ],
                        'writeback_rule' => 'must not write profile/basic or user_astro_profiles',
                    ],
                    'buddy_place' => [
                        'purpose' => 'future study, movie, meal, fitness, and companion context boundary',
                        'source_type' => 'future_buddy_request_or_preference',
                        'display_precision' => 'city_business_area_or_public_place_area',
                        'allowed_internal_use' => [
                            'buddy_future_contract',
                        ],
                        'user_visible_precision' => 'city_business_area_or_public_place_area',
                        'forbidden_user_visible_fields' => [
                            'lat',
                            'lng',
                            'exact_address',
                            'real_time_location',
                            'user_id',
                            'profile_id',
                        ],
                        'writeback_rule' => 'must not write profile/basic or user_astro_profiles',
                    ],
                ],
                'rules' => [
                    'static_contract' => true,
                    'reads_profile_basic' => false,
                    'reads_user_astro_profiles' => false,
                    'writes_profile_basic' => false,
                    'writes_user_astro_profiles' => false,
                    'uses_map_sdk' => false,
                    'requests_real_time_location_permission' => false,
                ],
            ],
            'meta' => [
                'notice' => 'static contract endpoint; no DB, auth, token, map SDK, real-time location, or user data access',
            ],
        ]);
    }
}
