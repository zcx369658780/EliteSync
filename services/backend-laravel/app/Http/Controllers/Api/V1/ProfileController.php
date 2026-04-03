<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Services\ChineseZodiacService;
use App\Services\BaziCanonicalService;
use App\Services\BirthLocationSolarTimeService;
use App\Services\UserAstroMirrorService;
use App\Services\WesternNatalCanonicalService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ProfileController extends Controller
{
    private function normalizeBirthTime(mixed $value): ?string
    {
        $candidate = trim((string) $value);
        if ($candidate === '') {
            return null;
        }

        return preg_match('/^\d{2}:\d{2}$/', $candidate) ? $candidate : null;
    }

    /**
     * @return array{profile:UserAstroProfile,user:object}
     */
    private function recomputeAstroFromBasicProfile(
        object $user,
        ?UserAstroProfile $profile,
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical
    ): array {
        $existingProfile = $profile ?? new UserAstroProfile(['user_id' => (int) $user->id]);
        $derivedBirthTime = $this->normalizeBirthTime($request->input('birth_time'))
            ?? $this->normalizeBirthTime($existingProfile->birth_time)
            ?? $this->normalizeBirthTime(data_get($user, 'private_natal_chart.true_solar_time'))
            ?? '12:00';
        $locationContext = $locationResolver->resolve([
            'birthday' => $user->birthday ? optional($user->birthday)->format('Y-m-d') : '',
            'birth_time' => $derivedBirthTime,
            'birth_place' => $user->private_birth_place ?? $existingProfile->birth_place ?? '',
            'birth_lat' => $user->private_birth_lat ?? $existingProfile->birth_lat,
            'birth_lng' => $user->private_birth_lng ?? $existingProfile->birth_lng,
        ]);

        $canonicalPayload = [
            'birthday' => $locationContext['effective_birthday'] ?: ($user->birthday ? optional($user->birthday)->format('Y-m-d') : ''),
            'gender' => (string) ($user->gender ?? ''),
            'birth_time' => $derivedBirthTime,
            'true_solar_time' => $locationContext['true_solar_time'] ?: $derivedBirthTime,
            'birth_place' => (string) ($user->private_birth_place ?? $existingProfile->birth_place ?? ''),
            'birth_lat' => $user->private_birth_lat ?? $existingProfile->birth_lat,
            'birth_lng' => $user->private_birth_lng ?? $existingProfile->birth_lng,
            'location_shift_minutes' => (int) ($locationContext['location_shift_minutes'] ?? 0),
            'longitude_offset_minutes' => (int) ($locationContext['longitude_offset_minutes'] ?? 0),
            'equation_of_time_minutes' => (int) ($locationContext['equation_of_time_minutes'] ?? 0),
            'location_source' => (string) ($locationContext['location_source'] ?? ''),
            'position_signature' => (string) ($locationContext['position_signature'] ?? ''),
            'da_yun' => (array) ($existingProfile->da_yun ?? []),
            'liu_nian' => (array) ($existingProfile->liu_nian ?? []),
            'wu_xing' => (array) ($existingProfile->wu_xing ?? []),
            'notes' => array_values(array_filter(array_merge(
                (array) ($existingProfile->notes ?? []),
                [
                    'recomputed_from_basic_profile',
                    'location_source:'.(string) ($locationContext['location_source'] ?? 'unknown'),
                    'location_shift_minutes:'.(string) ($locationContext['location_shift_minutes'] ?? 0),
                ]
            ))),
            'user_id' => (int) $user->id,
            'platform' => (string) $request->header('X-Platform', 'android'),
            'profile_version' => (int) $request->input('profile_version', 0),
        ];

        $normalized = $canonical->canonicalize($canonicalPayload);
        $ziwei = $ziweiCanonical->canonicalize($canonicalPayload);
        $westernPayload = array_merge($canonicalPayload, [
            'sun_sign' => (string) ($normalized['sun_sign'] ?? ($existingProfile->sun_sign ?? '')),
            'moon_sign' => (string) ($existingProfile->moon_sign ?? ''),
            'asc_sign' => (string) ($existingProfile->asc_sign ?? ''),
        ]);
        $western = $westernCanonical->compute($westernPayload);
        $notes = array_values(array_filter(array_merge(
            (array) ($existingProfile->notes ?? []),
            (array) ($normalized['notes'] ?? []),
            [
                'canonical_accuracy:'.(string) ($normalized['accuracy'] ?? 'legacy_estimate'),
                'canonical_confidence:'.(string) round((float) ($normalized['confidence'] ?? 0.6), 2),
                'western_engine:'.(string) ($western['engine'] ?? 'legacy_input'),
                'western_precision:'.(string) ($western['precision'] ?? 'legacy_estimate'),
                'western_confidence:'.(string) round((float) ($western['confidence'] ?? 0.6), 2),
                'ziwei_engine:'.(string) data_get($ziwei, 'ziwei.engine', 'ziwei_canonical_server'),
                'ziwei_precision:'.(string) data_get($ziwei, 'ziwei.precision', 'full_birth_data'),
                'ziwei_confidence:'.(string) round((float) ($ziwei['confidence'] ?? 0.6), 2),
            ]
        )));

        $profile = UserAstroProfile::query()->updateOrCreate(
            ['user_id' => (int) $user->id],
            [
                'birth_time' => $derivedBirthTime,
                'birth_place' => $canonicalPayload['birth_place'] ?: null,
                'birth_lat' => $canonicalPayload['birth_lat'],
                'birth_lng' => $canonicalPayload['birth_lng'],
                'sun_sign' => (string) ($western['sun_sign'] ?? $normalized['sun_sign'] ?? $existingProfile->sun_sign ?? ''),
                'moon_sign' => $western['moon_sign'] ?? $normalized['moon_sign'] ?? $existingProfile->moon_sign,
                'asc_sign' => $western['asc_sign'] ?? $normalized['asc_sign'] ?? $existingProfile->asc_sign,
                'bazi' => $normalized['bazi'] ?? $existingProfile->bazi,
                'true_solar_time' => $normalized['true_solar_time'] ?? $existingProfile->true_solar_time,
                'da_yun' => (array) ($normalized['da_yun'] ?? $existingProfile->da_yun ?? []),
                'liu_nian' => (array) ($normalized['liu_nian'] ?? $existingProfile->liu_nian ?? []),
                'wu_xing' => (array) ($normalized['wu_xing'] ?? $existingProfile->wu_xing ?? []),
                'ziwei' => (array) ($ziwei['ziwei'] ?? $existingProfile->ziwei ?? []),
                'notes' => $notes,
                'computed_at' => now(),
            ]
        );

        return ['profile' => $profile, 'user' => $user];
    }

    public function basic(Request $request): JsonResponse
    {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        return response()->json([
            'id' => $user->id,
            'name' => $user->name,
            'phone' => $user->phone,
            'birthday' => optional($user->birthday)->format('Y-m-d'),
            'birth_time' => $profile?->birth_time,
            'zodiac_animal' => $user->zodiac_animal,
            'gender' => $user->gender,
            'city' => $user->city,
            'relationship_goal' => $user->relationship_goal,
            'birth_place' => $user->private_birth_place,
            'birth_lat' => $user->private_birth_lat,
            'birth_lng' => $user->private_birth_lng,
            'realname_verified' => (bool) $user->realname_verified,
        ]);
    }

    public function saveBasic(
        Request $request,
        ChineseZodiacService $zodiacService,
        UserAstroMirrorService $mirror,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical,
        BirthLocationSolarTimeService $locationResolver
    ): JsonResponse
    {
        $data = $request->validate([
            'birthday' => ['nullable', 'date_format:Y-m-d'],
            'birth_time' => ['nullable', 'regex:/^\d{2}:\d{2}$/'],
            'name' => ['nullable', 'string', 'max:255'],
            'gender' => ['required', 'in:male,female'],
            'city' => ['required', 'string', 'max:64'],
            'relationship_goal' => ['required', 'in:marriage,dating,friendship'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
        ]);

        $user = $request->user();
        if (array_key_exists('birthday', $data)) {
            $user->birthday = $data['birthday'] ?: null;
            $user->zodiac_animal = $zodiacService->fromBirthdayString($data['birthday'] ?? null);
        }
        if (array_key_exists('name', $data)) {
            $user->name = $data['name'] ?: null;
        }
        $user->gender = $data['gender'];
        $user->city = $data['city'];
        $user->relationship_goal = $data['relationship_goal'];
        $user->private_birth_place = $data['birth_place'] ?? null;
        $user->private_birth_lat = $data['birth_lat'] ?? null;
        $user->private_birth_lng = $data['birth_lng'] ?? null;
        $user->save();

        $profile = UserAstroProfile::query()->where('user_id', (int) $user->id)->first();
        $computed = $this->recomputeAstroFromBasicProfile(
            $user,
            $profile,
            $request,
            $locationResolver,
            $canonical,
            $westernCanonical,
            $ziweiCanonical
        );
        $mirror->syncFromAstroProfile($user, $computed['profile']);

        return response()->json([
            'ok' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'birth_time' => $computed['profile']->birth_time,
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'birth_place' => $user->private_birth_place,
                'birth_lat' => $user->private_birth_lat,
                'birth_lng' => $user->private_birth_lng,
                'realname_verified' => (bool) $user->realname_verified,
            ],
        ]);
    }

    public function saveCity(Request $request): JsonResponse
    {
        $data = $request->validate([
            'city' => ['required', 'string', 'max:64'],
        ]);

        $user = $request->user();
        $user->city = trim((string) $data['city']);
        $user->save();

        return response()->json([
            'ok' => true,
            'city' => $user->city,
        ]);
    }
}
