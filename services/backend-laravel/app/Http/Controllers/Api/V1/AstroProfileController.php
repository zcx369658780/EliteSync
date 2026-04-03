<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Services\BaziCanonicalService;
use App\Services\BirthLocationSolarTimeService;
use App\Services\PythonAstroRenderService;
use App\Services\UserAstroMirrorService;
use App\Services\WesternNatalCanonicalService;
use App\Services\ZiweiCanonicalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AstroProfileController extends Controller
{
    public function showSummary(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal($request, $locationResolver, $pythonAstro, false);
    }

    public function showChart(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal($request, $locationResolver, $pythonAstro, true);
    }

    public function show(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        return $this->showInternal(
            $request,
            $locationResolver,
            $pythonAstro,
            $request->boolean('include_chart', true)
        );
    }

    private function showInternal(
        Request $request,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro,
        bool $includeChart
    ): JsonResponse {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        if (! $profile) {
            return response()->json([
                'exists' => false,
                'profile' => null,
            ]);
        }

        $profile->loadMissing('user');

        $profileData = $this->formatProfile($profile, $locationResolver);

        return response()->json([
            'exists' => true,
            'profile' => $includeChart
                ? $this->appendPythonNatalChart($profileData, $profile, $pythonAstro)
                : $profileData,
        ]);
    }

    public function save(
        Request $request,
        UserAstroMirrorService $mirror,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical,
        ZiweiCanonicalService $ziweiCanonical,
        BirthLocationSolarTimeService $locationResolver,
        PythonAstroRenderService $pythonAstro
    ): JsonResponse {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();
        $data = $request->validate([
            'birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'sun_sign' => ['nullable', 'string', 'max:32'],
            'moon_sign' => ['nullable', 'string', 'max:32'],
            'asc_sign' => ['nullable', 'string', 'max:32'],
            'bazi' => ['nullable', 'string', 'max:128'],
            'true_solar_time' => ['nullable', 'string', 'max:32'],
            'da_yun' => ['nullable', 'array'],
            'da_yun.*.index' => ['required_with:da_yun', 'integer', 'min:0'],
            'da_yun.*.gan_zhi' => ['required_with:da_yun', 'string', 'max:16'],
            'da_yun.*.start_year' => ['required_with:da_yun', 'integer'],
            'da_yun.*.end_year' => ['required_with:da_yun', 'integer'],
            'da_yun.*.start_age' => ['required_with:da_yun', 'integer', 'min:0'],
            'da_yun.*.end_age' => ['required_with:da_yun', 'integer', 'min:0'],
            'liu_nian' => ['nullable', 'array'],
            'liu_nian.*.year' => ['required_with:liu_nian', 'integer'],
            'liu_nian.*.age' => ['required_with:liu_nian', 'integer', 'min:0'],
            'liu_nian.*.gan_zhi' => ['required_with:liu_nian', 'string', 'max:16'],
            'wu_xing' => ['nullable', 'array'],
            'wu_xing.木' => ['nullable', 'integer', 'min:0'],
            'wu_xing.火' => ['nullable', 'integer', 'min:0'],
            'wu_xing.土' => ['nullable', 'integer', 'min:0'],
            'wu_xing.金' => ['nullable', 'integer', 'min:0'],
            'wu_xing.水' => ['nullable', 'integer', 'min:0'],
            'notes' => ['nullable', 'array'],
            'notes.*' => ['string', 'max:255'],
        ]);

        $locationContext = $locationResolver->resolve([
            'birthday' => $user->birthday ? optional($user->birthday)->format('Y-m-d') : '',
            'birth_time' => $data['birth_time'],
            'birth_place' => $data['birth_place'] ?? $profile?->birth_place ?? '',
            'birth_lat' => $data['birth_lat'] ?? $profile?->birth_lat,
            'birth_lng' => $data['birth_lng'] ?? $profile?->birth_lng,
        ]);

        $canonicalPayload = $data;
        $canonicalPayload['birthday'] = $locationContext['effective_birthday'] ?: ($user->birthday
            ? optional($user->birthday)->format('Y-m-d')
            : '');
        $canonicalPayload['birth_time'] = $data['birth_time'];
        $canonicalPayload['true_solar_time'] = $locationContext['true_solar_time'] ?: $data['birth_time'];
        $canonicalPayload['gender'] = (string) ($user->gender ?? '');
        $canonicalPayload['user_id'] = (int) $user->id;
        $canonicalPayload['platform'] = (string) ($request->header('X-Platform', 'android'));
        $canonicalPayload['profile_version'] = (int) $request->input('profile_version', 0);
        $canonicalPayload['location_shift_minutes'] = (int) ($locationContext['location_shift_minutes'] ?? 0);
        $canonicalPayload['longitude_offset_minutes'] = (int) ($locationContext['longitude_offset_minutes'] ?? 0);
        $canonicalPayload['equation_of_time_minutes'] = (int) ($locationContext['equation_of_time_minutes'] ?? 0);
        $canonicalPayload['location_source'] = (string) ($locationContext['location_source'] ?? '');
        $canonicalPayload['position_signature'] = (string) ($locationContext['position_signature'] ?? '');
        $canonicalPayload['notes'] = array_values(array_filter(array_merge(
            (array) ($data['notes'] ?? []),
            [
                'location_source:'.(string) ($locationContext['location_source'] ?? 'unknown'),
                'location_shift_minutes:'.(string) ($locationContext['location_shift_minutes'] ?? 0),
            ]
        )));
        $normalized = $canonical->canonicalize($canonicalPayload);
        $ziwei = $ziweiCanonical->canonicalize($canonicalPayload);
        $westernPayload = array_merge($canonicalPayload, [
            'sun_sign' => (string) ($normalized['sun_sign'] ?? ''),
            'moon_sign' => $normalized['moon_sign'] ?? ($data['moon_sign'] ?? null),
            'asc_sign' => $normalized['asc_sign'] ?? ($data['asc_sign'] ?? null),
        ]);
        $western = $westernCanonical->compute($westernPayload);
        $notes = array_values(array_filter(array_merge(
            (array) ($data['notes'] ?? []),
            (array) ($normalized['notes'] ?? []),
            [
                'canonical_accuracy:'.(string) ($normalized['accuracy'] ?? 'legacy_estimate'),
                'canonical_confidence:'.(string) round((float) ($normalized['confidence'] ?? 0.6), 2),
                'western_engine:'.(string) ($western['engine'] ?? 'legacy_input'),
                'western_precision:'.(string) ($western['precision'] ?? 'legacy_estimate'),
                'western_confidence:'.(string) round((float) ($western['confidence'] ?? 0.6), 2),
                'western_degraded:'.((bool) ($western['degraded'] ?? false) ? '1' : '0'),
                'western_degrade_reason:'.(string) ($western['degrade_reason'] ?? ''),
                'western_rollout_enabled:'.((bool) ($western['rollout_enabled'] ?? false) ? '1' : '0'),
                'western_rollout_reason:'.(string) ($western['rollout_reason'] ?? ''),
                'ziwei_engine:'.(string) data_get($ziwei, 'ziwei.engine', 'ziwei_canonical_server'),
                'ziwei_precision:'.(string) data_get($ziwei, 'ziwei.precision', 'full_birth_data'),
                'ziwei_confidence:'.(string) round((float) ($ziwei['confidence'] ?? 0.6), 2),
            ]
        )));

        $profile = UserAstroProfile::query()->updateOrCreate(
            ['user_id' => (int) $user->id],
            [
                'birth_time' => $data['birth_time'],
                'birth_place' => $data['birth_place'] ?? null,
                'birth_lat' => $data['birth_lat'] ?? null,
                'birth_lng' => $data['birth_lng'] ?? null,
                'sun_sign' => (string) ($western['sun_sign'] ?? $normalized['sun_sign'] ?? $data['sun_sign'] ?? ''),
                'moon_sign' => $western['moon_sign'] ?? $normalized['moon_sign'] ?? ($data['moon_sign'] ?? null),
                'asc_sign' => $western['asc_sign'] ?? $normalized['asc_sign'] ?? ($data['asc_sign'] ?? null),
                'bazi' => $normalized['bazi'] ?? ($data['bazi'] ?? null),
                'true_solar_time' => $normalized['true_solar_time'] ?? ($data['true_solar_time'] ?? null),
                'da_yun' => (array) ($normalized['da_yun'] ?? ($data['da_yun'] ?? [])),
                'liu_nian' => (array) ($normalized['liu_nian'] ?? ($data['liu_nian'] ?? [])),
                'wu_xing' => (array) ($normalized['wu_xing'] ?? ($data['wu_xing'] ?? [])),
                'ziwei' => (array) ($ziwei['ziwei'] ?? []),
                'notes' => $notes,
                'computed_at' => now(),
            ]
        );

        // Single direction mirror: canonical source is user_astro_profiles.
        $mirror->syncFromAstroProfile($user, $profile);
        $profile->loadMissing('user');

        $profilePayload = $this->appendPythonNatalChart(
            $this->formatProfile($profile, $locationResolver),
            $profile,
            $pythonAstro
        );

        return response()->json([
            'ok' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'phone' => $user->phone,
                'birthday' => optional($user->birthday)->format('Y-m-d'),
                'birth_time' => $profile->birth_time,
                'zodiac_animal' => $user->zodiac_animal,
                'gender' => $user->gender,
                'city' => $user->city,
                'relationship_goal' => $user->relationship_goal,
                'birth_place' => $user->private_birth_place,
                'birth_lat' => $user->private_birth_lat,
                'birth_lng' => $user->private_birth_lng,
                'realname_verified' => (bool) $user->realname_verified,
            ],
            'profile' => $profilePayload,
        ]);
    }

    /**
     * @param array<string,mixed> $profileData
     * @return array<string,mixed>
     */
    private function appendPythonNatalChart(array $profileData, UserAstroProfile $profile, PythonAstroRenderService $pythonAstro): array
    {
        $cached = [];
        $user = $profile->user;
        if ($user && is_array($user->private_natal_chart ?? null)) {
            $cached = (array) $user->private_natal_chart;
        }

        $payload = [
            'name' => (string) ($user?->name ?: $user?->nickname ?: 'EliteSync'),
            'birthday' => (string) ($user?->birthday ? optional($user->birthday)->format('Y-m-d') : ($profile->birthday ?? '')),
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'tz_str' => (string) ($profile->tz_str ?? 'Asia/Shanghai'),
        ];

        $rendered = $pythonAstro->render($payload);
        if (is_array($rendered) && ! empty($rendered)) {
            if ($user) {
                $user->forceFill(['private_natal_chart' => array_merge($cached, $rendered)])->save();
            }
            return array_merge($profileData, $rendered);
        }

        if (! empty($cached)) {
            return array_merge($profileData, $cached);
        }

        return $profileData;
    }

    /**
     * @return array<string,mixed>
     */
    private function formatProfile(UserAstroProfile $profile, BirthLocationSolarTimeService $locationResolver): array
    {
        $notes = (array) ($profile->notes ?? []);
        $accuracy = null;
        $confidence = null;
        $westernEngine = null;
        $westernPrecision = null;
        $westernConfidence = null;
        $westernDegraded = null;
        $westernDegradeReason = null;
        $westernRolloutEnabled = null;
        $westernRolloutReason = null;
        foreach ($notes as $n) {
            $s = (string) $n;
            if (str_starts_with($s, 'canonical_accuracy:')) {
                $accuracy = substr($s, strlen('canonical_accuracy:'));
            }
            if (str_starts_with($s, 'canonical_confidence:')) {
                $confidence = (float) substr($s, strlen('canonical_confidence:'));
            }
            if (str_starts_with($s, 'western_engine:')) {
                $westernEngine = substr($s, strlen('western_engine:'));
            }
            if (str_starts_with($s, 'western_precision:')) {
                $westernPrecision = substr($s, strlen('western_precision:'));
            }
            if (str_starts_with($s, 'western_confidence:')) {
                $westernConfidence = (float) substr($s, strlen('western_confidence:'));
            }
            if (str_starts_with($s, 'western_degraded:')) {
                $westernDegraded = substr($s, strlen('western_degraded:')) === '1';
            }
            if (str_starts_with($s, 'western_degrade_reason:')) {
                $westernDegradeReason = substr($s, strlen('western_degrade_reason:'));
            }
            if (str_starts_with($s, 'western_rollout_enabled:')) {
                $westernRolloutEnabled = substr($s, strlen('western_rollout_enabled:')) === '1';
            }
            if (str_starts_with($s, 'western_rollout_reason:')) {
                $westernRolloutReason = substr($s, strlen('western_rollout_reason:'));
            }
        }

        $locationContext = $locationResolver->resolve([
            'birthday' => $profile->user?->birthday ? optional($profile->user->birthday)->format('Y-m-d') : '',
            'birth_time' => (string) ($profile->birth_time ?? ''),
            'birth_place' => (string) ($profile->birth_place ?? ''),
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
        ]);

        return [
            'birthday' => $profile->user?->birthday ? optional($profile->user->birthday)->format('Y-m-d') : '',
            'birth_time' => $profile->birth_time,
            'birth_place' => $profile->birth_place,
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'sun_sign' => $profile->sun_sign,
            'moon_sign' => $profile->moon_sign,
            'asc_sign' => $profile->asc_sign,
            'bazi' => $profile->bazi,
            'true_solar_time' => $profile->true_solar_time,
            'location_shift_minutes' => $locationContext['location_shift_minutes'] ?? 0,
            'longitude_offset_minutes' => $locationContext['longitude_offset_minutes'] ?? 0,
            'equation_of_time_minutes' => $locationContext['equation_of_time_minutes'] ?? 0,
            'position_signature' => $locationContext['position_signature'] ?? '',
            'location_source' => $locationContext['location_source'] ?? '',
            'da_yun' => $profile->da_yun ?? [],
            'liu_nian' => $profile->liu_nian ?? [],
            'wu_xing' => $profile->wu_xing ?? [],
            'ziwei' => $profile->ziwei ?? [],
            'notes' => $notes,
            'accuracy' => $accuracy,
            'confidence' => $confidence,
            'western_engine' => $westernEngine,
            'western_precision' => $westernPrecision,
            'western_confidence' => $westernConfidence,
            'western_degraded' => $westernDegraded,
            'western_degrade_reason' => $westernDegradeReason,
            'western_rollout_enabled' => $westernRolloutEnabled,
            'western_rollout_reason' => $westernRolloutReason,
            'computed_at' => optional($profile->computed_at)->toIso8601String(),
        ];
    }
}
