<?php

namespace App\Services;

class AstroCanonicalRolloutService
{
    /**
     * @param array<string,mixed> $payload
     * @return array{enabled:bool,reason:string}
     */
    public function decideBazi(array $payload): array
    {
        return $this->decide((array) config('astro_rollout.bazi', []), $payload, 'bazi');
    }

    /**
     * @param array<string,mixed> $payload
     * @return array{enabled:bool,reason:string}
     */
    public function decideWestern(array $payload): array
    {
        return $this->decide((array) config('astro_rollout.western', []), $payload, 'western');
    }

    /**
     * @param array<string,mixed> $payload
     * @return array{enabled:bool,reason:string}
     */
    public function decideZiwei(array $payload): array
    {
        return $this->decide((array) config('astro_rollout.ziwei', []), $payload, 'ziwei');
    }

    /**
     * @param array<string,mixed> $rule
     * @param array<string,mixed> $payload
     * @return array{enabled:bool,reason:string}
     */
    private function decide(array $rule, array $payload, string $domain): array
    {
        $platform = strtolower(trim((string) ($payload['platform'] ?? '')));
        $userId = (int) ($payload['user_id'] ?? 0);
        $profileVersion = (int) ($payload['profile_version'] ?? 0);
        $enabled = (bool) ($rule['enabled'] ?? false);
        $minProfileVersion = (int) ($rule['min_profile_version'] ?? 0);
        /** @var array<int,int> $whitelist */
        $whitelist = array_values(array_filter(
            array_map(fn ($v) => (int) $v, (array) ($rule['whitelist_user_ids'] ?? [])),
            fn ($v) => $v > 0
        ));
        $overrides = (array) ($rule['platform_overrides'] ?? []);

        if ($platform !== '') {
            $override = strtolower(trim((string) ($overrides[$platform] ?? '')));
            if ($override === 'canonical') {
                return ['enabled' => true, 'reason' => "{$domain}_platform_override:canonical"];
            }
            if ($override === 'legacy') {
                return ['enabled' => false, 'reason' => "{$domain}_platform_override:legacy"];
            }
        }

        if ($enabled) {
            if ($minProfileVersion > 0 && $profileVersion > 0 && $profileVersion < $minProfileVersion) {
                return ['enabled' => false, 'reason' => "{$domain}_below_min_profile_version"];
            }
            return ['enabled' => true, 'reason' => "{$domain}_global_enabled"];
        }

        if ($userId > 0 && in_array($userId, $whitelist, true)) {
            return ['enabled' => true, 'reason' => "{$domain}_whitelist"];
        }

        return ['enabled' => false, 'reason' => "{$domain}_global_disabled"];
    }
}
