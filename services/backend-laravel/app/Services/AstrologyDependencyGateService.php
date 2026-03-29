<?php

namespace App\Services;

class AstrologyDependencyGateService
{
    /**
     * @return array{allowed:bool,reason:string}
     */
    public function allow(string $dependency): array
    {
        $key = strtolower(trim($dependency));
        $cfg = (array) config('astrology_dependency_gate.dependencies', []);
        $row = (array) ($cfg[$key] ?? []);
        $blockedDefault = (bool) ($row['blocked_default'] ?? false);
        $reason = (string) ($row['reason'] ?? '');
        $researchMode = (bool) config('astrology_dependency_gate.research_mode', false);

        if (!$blockedDefault) {
            return ['allowed' => true, 'reason' => $reason];
        }
        if ($researchMode) {
            return ['allowed' => true, 'reason' => 'research_mode_enabled'];
        }

        return ['allowed' => false, 'reason' => $reason !== '' ? $reason : 'blocked_by_license_gate'];
    }
}

