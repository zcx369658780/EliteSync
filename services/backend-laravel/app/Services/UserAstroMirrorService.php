<?php

namespace App\Services;

use App\Models\User;
use App\Models\UserAstroProfile;

class UserAstroMirrorService
{
    public function syncFromAstroProfile(User $user, UserAstroProfile $profile): void
    {
        $user->forceFill([
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
                'computed_at' => optional($profile->computed_at)->toIso8601String(),
            ],
        ])->save();
    }
}

