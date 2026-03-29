<?php

namespace App\Services;

class BaziCanonicalService
{
    public function __construct(
        private readonly LunarPhpBaziEngine $lunarEngine,
        private readonly LegacyClientBaziEngine $legacyEngine,
        private readonly AstroCanonicalRolloutService $rollout
    ) {
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function canonicalize(array $payload): array
    {
        $decision = $this->rollout->decideBazi($payload);
        $engine = (bool) ($decision['enabled'] ?? false) ? $this->lunarEngine : $this->legacyEngine;
        $out = $engine->canonicalize($payload);
        $notes = (array) ($out['notes'] ?? []);
        $notes[] = 'rollout_bazi:'.(string) ($decision['reason'] ?? 'unknown');
        $out['notes'] = array_values(array_unique(array_filter(array_map(
            fn ($v) => trim((string) $v),
            $notes
        ))));
        return $out;
    }
}
