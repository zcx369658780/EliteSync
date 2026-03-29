<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
use App\Services\BaziCanonicalService;
use App\Services\UserAstroMirrorService;
use App\Services\WesternNatalCanonicalService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AstroProfileController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $user = $request->user();
        $profile = UserAstroProfile::query()
            ->where('user_id', (int) $user->id)
            ->first();

        if (!$profile) {
            return response()->json([
                'exists' => false,
                'profile' => null,
            ]);
        }

        return response()->json([
            'exists' => true,
            'profile' => $this->formatProfile($profile),
        ]);
    }

    public function save(
        Request $request,
        UserAstroMirrorService $mirror,
        BaziCanonicalService $canonical,
        WesternNatalCanonicalService $westernCanonical
    ): JsonResponse
    {
        $user = $request->user();
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

        $canonicalPayload = $data;
        $canonicalPayload['birthday'] = $user->birthday
            ? optional($user->birthday)->format('Y-m-d')
            : '';
        $canonicalPayload['gender'] = (string) ($user->gender ?? '');
        $canonicalPayload['user_id'] = (int) $user->id;
        $canonicalPayload['platform'] = (string) ($request->header('X-Platform', 'android'));
        $canonicalPayload['profile_version'] = (int) $request->input('profile_version', 0);
        $normalized = $canonical->canonicalize($canonicalPayload);
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
                'notes' => $notes,
                'computed_at' => now(),
            ]
        );

        // Single direction mirror: canonical source is user_astro_profiles.
        $mirror->syncFromAstroProfile($user, $profile);

        return response()->json([
            'ok' => true,
            'profile' => $this->formatProfile($profile),
        ]);
    }

    /**
     * @return array<string,mixed>
     */
    private function formatProfile(UserAstroProfile $profile): array
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
        return [
            'birth_time' => $profile->birth_time,
            'birth_place' => $profile->birth_place,
            'birth_lat' => $profile->birth_lat,
            'birth_lng' => $profile->birth_lng,
            'sun_sign' => $profile->sun_sign,
            'moon_sign' => $profile->moon_sign,
            'asc_sign' => $profile->asc_sign,
            'bazi' => $profile->bazi,
            'true_solar_time' => $profile->true_solar_time,
            'da_yun' => $profile->da_yun ?? [],
            'liu_nian' => $profile->liu_nian ?? [],
            'wu_xing' => $profile->wu_xing ?? [],
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
