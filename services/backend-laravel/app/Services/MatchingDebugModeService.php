<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;

class MatchingDebugModeService
{
    private const CACHE_KEY = 'matching_debug_include_synthetic_users';

    public function includeSyntheticUsers(): bool
    {
        $cached = Cache::get(self::CACHE_KEY);
        if ($cached === null) {
            return (bool) config('matching.debug.include_synthetic_users_default', false);
        }

        return filter_var($cached, FILTER_VALIDATE_BOOL);
    }

    public function setIncludeSyntheticUsers(bool $enabled): void
    {
        Cache::forever(self::CACHE_KEY, $enabled);
    }

    public function reset(): void
    {
        Cache::forget(self::CACHE_KEY);
    }
}

