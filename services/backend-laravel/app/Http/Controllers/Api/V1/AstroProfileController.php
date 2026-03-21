<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserAstroProfile;
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

    public function save(Request $request): JsonResponse
    {
        $user = $request->user();
        $data = $request->validate([
            'birth_time' => ['required', 'regex:/^\d{2}:\d{2}$/'],
            'birth_place' => ['nullable', 'string', 'max:255'],
            'birth_lat' => ['nullable', 'numeric', 'between:-90,90'],
            'birth_lng' => ['nullable', 'numeric', 'between:-180,180'],
            'sun_sign' => ['required', 'string', 'max:32'],
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

        $profile = UserAstroProfile::query()->updateOrCreate(
            ['user_id' => (int) $user->id],
            [
                'birth_time' => $data['birth_time'],
                'birth_place' => $data['birth_place'] ?? null,
                'birth_lat' => $data['birth_lat'] ?? null,
                'birth_lng' => $data['birth_lng'] ?? null,
                'sun_sign' => $data['sun_sign'],
                'moon_sign' => $data['moon_sign'] ?? null,
                'asc_sign' => $data['asc_sign'] ?? null,
                'bazi' => $data['bazi'] ?? null,
                'true_solar_time' => $data['true_solar_time'] ?? null,
                'da_yun' => $data['da_yun'] ?? [],
                'liu_nian' => $data['liu_nian'] ?? [],
                'wu_xing' => $data['wu_xing'] ?? [],
                'notes' => $data['notes'] ?? [],
                'computed_at' => now(),
            ]
        );

        $user->forceFill([
            'public_zodiac_sign' => $data['sun_sign'],
            'private_bazi' => $data['bazi'] ?? null,
            'private_birth_place' => $data['birth_place'] ?? null,
            'private_birth_lat' => $data['birth_lat'] ?? null,
            'private_birth_lng' => $data['birth_lng'] ?? null,
            'private_natal_chart' => [
                'moon_sign' => $data['moon_sign'] ?? null,
                'asc_sign' => $data['asc_sign'] ?? null,
                'true_solar_time' => $data['true_solar_time'] ?? null,
                'da_yun' => $data['da_yun'] ?? [],
                'liu_nian' => $data['liu_nian'] ?? [],
                'wu_xing' => $data['wu_xing'] ?? [],
                'notes' => $data['notes'] ?? [],
            ],
        ])->save();

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
            'notes' => $profile->notes ?? [],
            'computed_at' => optional($profile->computed_at)->toIso8601String(),
        ];
    }
}
