<?php

namespace App\Services;

class WesternNatalCanonicalService
{
    public function __construct(
        private readonly WesternNatalEngine $engine,
        private readonly AstroCanonicalRolloutService $rollout
    ) {
    }

    /**
     * @param array<string,mixed> $payload
     * @return array<string,mixed>
     */
    public function compute(array $payload): array
    {
        $decision = $this->rollout->decideWestern($payload);
        $out = $this->engine->compute($payload);
        $out['rollout_enabled'] = (bool) ($decision['enabled'] ?? false);
        $out['rollout_reason'] = (string) ($decision['reason'] ?? 'unknown');

        // Before production western engine is wired, keep response explicit.
        if (!((bool) ($decision['enabled'] ?? false))) {
            $out['degraded'] = true;
            $reason = trim((string) ($out['degrade_reason'] ?? ''));
            $mark = 'western_rollout_disabled';
            $out['degrade_reason'] = $reason === '' ? $mark : ($reason.'|'.$mark);
            $out['confidence'] = min((float) ($out['confidence'] ?? 0.66), 0.66);
        }
        return $out;
    }
}
