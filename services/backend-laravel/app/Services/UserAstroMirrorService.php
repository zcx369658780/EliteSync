<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserAstroProfile;

class UserAstroMirrorService
{
    public function __construct(private readonly ChineseZodiacService $zodiacService)
    {
    }

    public function syncFromAstroProfile(User $user, UserAstroProfile $profile): void
    {
        // Zodiac must prefer year-pillar derivation from bazi.
        $zodiac = $this->zodiacService->fromPreferredSources(
            (string) ($profile->bazi ?? ''),
            (string) ($user->birthday ?? '')
        );

        $notes = (array) ($profile->notes ?? []);
        $westernEngine = null;
        $westernPrecision = null;
        $westernConfidence = null;
        foreach ($notes as $n) {
            $s = (string) $n;
            if (str_starts_with($s, 'western_engine:')) {
                $westernEngine = substr($s, strlen('western_engine:'));
            }
            if (str_starts_with($s, 'western_precision:')) {
                $westernPrecision = substr($s, strlen('western_precision:'));
            }
            if (str_starts_with($s, 'western_confidence:')) {
                $westernConfidence = (float) substr($s, strlen('western_confidence:'));
            }
        }

        $user->forceFill([
            'zodiac_animal' => $zodiac ?: $user->zodiac_animal,
            'public_zodiac_sign' => $profile->sun_sign ?: $user->public_zodiac_sign,
            'private_bazi' => $profile->bazi,
            'private_birth_place' => $profile->birth_place,
            'private_birth_lat' => $profile->birth_lat,
            'private_birth_lng' => $profile->birth_lng,
            'private_natal_chart' => [
                'moon_sign' => $profile->moon_sign,
                'asc_sign' => $profile->asc_sign,
                'true_solar_time' => $profile->true_solar_time,
                'da_yun' => $profile->da_yun ?? [],
                'liu_nian' => $profile->liu_nian ?? [],
                'wu_xing' => $profile->wu_xing ?? [],
                'notes' => $profile->notes ?? [],
                'engine' => $westernEngine,
                'precision' => $westernPrecision,
                'confidence' => $westernConfidence,
                'computed_at' => optional($profile->computed_at)->toIso8601String(),
            ],
        ])->save();
    }
}
