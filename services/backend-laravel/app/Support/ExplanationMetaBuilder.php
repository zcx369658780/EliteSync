<?php

namespace App\Support;

class ExplanationMetaBuilder
{
    /**
     * @param array<string,mixed> $module
     * @return array{
     *   engine_source:string,
     *   engine_mode:string,
     *   data_quality:string,
     *   precision_level:string,
     *   confidence_tier:string,
     *   confidence_reason:list<string>,
     *   display_guard:array{
     *     allow_high_confidence_badge:bool,
     *     allow_strong_evidence_badge:bool,
     *     allow_precise_wording:bool
     *   }
     * }
     */
    public function build(array $module): array
    {
        $confidence = (float) ($module['confidence'] ?? 0.5);
        $degraded = (bool) ($module['degraded'] ?? false);

        $source = trim((string) (
            $module['engine_source']
            ?? data_get($module, 'evidence.engine_source', '')
            ?? ''
        ));
        if ($source === '') {
            $source = 'unknown';
        }

        $mode = trim((string) ($module['engine_mode'] ?? ''));
        if ($mode === '') {
            $mode = $this->inferEngineMode($source, $degraded);
        }
        $mode = $this->applyWesternPolicyMode((string) ($module['key'] ?? ''), $mode);

        $dataQuality = trim((string) ($module['data_quality'] ?? ''));
        if ($dataQuality === '') {
            $dataQuality = $this->inferDataQuality($module);
        }

        $precision = trim((string) ($module['precision_level'] ?? ''));
        if ($precision === '') {
            $precision = $this->inferPrecisionLevel($confidence, $degraded, $dataQuality);
        }

        $reasons = $this->buildConfidenceReason($module, $mode, $dataQuality, $precision, $source);
        $tier = $this->confidenceTier($confidence, $degraded);
        $guard = $this->buildDisplayGuard($module, $confidence, $mode, $dataQuality, $precision, $degraded);

        return [
            'engine_source' => $source,
            'engine_mode' => $mode,
            'data_quality' => $dataQuality,
            'precision_level' => $precision,
            'confidence_tier' => $tier,
            'confidence_reason' => $reasons,
            'display_guard' => $guard,
        ];
    }

    private function inferEngineMode(string $source, bool $degraded): string
    {
        $v = strtolower($source);
        if (str_contains($v, 'legacy')) {
            return 'legacy';
        }
        if (str_contains($v, 'fallback')) {
            return 'fallback';
        }
        if ($degraded) {
            return 'hybrid';
        }
        return 'canonical';
    }

    private function applyWesternPolicyMode(string $key, string $mode): string
    {
        $k = strtolower(trim($key));
        if (!in_array($k, ['natal_chart', 'pair_chart'], true)) {
            return $mode;
        }
        $policyMode = strtolower(trim((string) config('western_policy.mode', 'legacy_display')));
        if ($policyMode === 'canonical_authorized') {
            return $mode;
        }
        // Before canonical authorization, western modules must not be treated as strict canonical.
        if ($mode === 'canonical') {
            return $policyMode === 'hybrid_candidate' ? 'hybrid' : 'legacy';
        }
        return $mode;
    }

    /**
     * @param array<string,mixed> $module
     */
    private function inferDataQuality(array $module): string
    {
        $degradeReason = strtolower(trim((string) ($module['degrade_reason'] ?? '')));
        if ($degradeReason === 'date_only') {
            return 'date_only';
        }
        if ($degradeReason !== '' || (bool) ($module['degraded'] ?? false)) {
            return 'partial_unknown';
        }
        return 'exact_time+location';
    }

    private function inferPrecisionLevel(float $confidence, bool $degraded, string $dataQuality): string
    {
        if ($degraded || $dataQuality === 'date_only') {
            return 'estimated';
        }
        if ($confidence >= 0.85) {
            return 'high';
        }
        if ($confidence >= 0.65) {
            return 'medium';
        }
        return 'low';
    }

    /**
     * @param array<string,mixed> $module
     * @return list<string>
     */
    private function buildConfidenceReason(
        array $module,
        string $mode,
        string $dataQuality,
        string $precision,
        string $source
    ): array {
        $reasons = [];
        $degradeReason = trim((string) ($module['degrade_reason'] ?? ''));
        if ($degradeReason !== '') {
            $reasons[] = $degradeReason;
        }
        $reasons[] = 'engine_mode:'.$mode;
        $reasons[] = 'data_quality:'.$dataQuality;
        $reasons[] = 'precision:'.$precision;
        $reasons[] = 'engine_source:'.$source;
        return array_values(array_unique(array_filter($reasons)));
    }

    /**
     * @param array<string,mixed> $module
     * @return array{
     *   allow_high_confidence_badge:bool,
     *   allow_strong_evidence_badge:bool,
     *   allow_precise_wording:bool
     * }
     */
    private function buildDisplayGuard(
        array $module,
        float $confidence,
        string $mode,
        string $dataQuality,
        string $precision,
        bool $degraded
    ): array {
        $cfg = (array) config('display_guard', []);
        $cCfg = (array) ($cfg['confidence'] ?? []);
        $eCfg = (array) ($cfg['engine'] ?? []);
        $pCfg = (array) ($cfg['precision'] ?? []);
        $dCfg = (array) ($cfg['data_quality'] ?? []);
        $evCfg = (array) ($cfg['evidence'] ?? []);

        $highThreshold = (float) ($cCfg['high_threshold'] ?? 0.82);
        $strongThreshold = (float) ($cCfg['strong_evidence_threshold'] ?? 0.76);
        $preciseThreshold = (float) ($cCfg['precise_wording_threshold'] ?? 0.72);

        $allowModes = (array) ($eCfg['allow_high_confidence_modes'] ?? ['canonical']);
        $denyModes = (array) ($eCfg['deny_high_confidence_modes'] ?? ['legacy', 'fallback', 'hybrid']);
        $allowPrecision = (array) ($pCfg['allow_high_confidence_levels'] ?? ['high', 'medium']);
        $denyPrecision = (array) ($pCfg['deny_high_confidence_levels'] ?? ['low', 'estimated']);
        $allowDataQuality = (array) ($dCfg['allow_high_confidence_levels'] ?? ['exact_time+location', 'exact_time_only']);
        $denyDataQuality = (array) ($dCfg['deny_high_confidence_levels'] ?? ['date_only', 'partial_unknown']);
        $coreMin = max(1, (int) ($evCfg['core_min_count'] ?? 2));

        $coreTags = array_values((array) ($module['core_tags'] ?? []));
        $coreCount = count($coreTags) > 0
            ? count($coreTags)
            : count((array) ($module['evidence_tags'] ?? []));

        $modeAllowed = in_array($mode, $allowModes, true) && !in_array($mode, $denyModes, true);
        $precisionAllowed = in_array($precision, $allowPrecision, true) && !in_array($precision, $denyPrecision, true);
        $qualityAllowed = in_array($dataQuality, $allowDataQuality, true) && !in_array($dataQuality, $denyDataQuality, true);

        $allowHigh = !$degraded
            && $confidence >= $highThreshold
            && $modeAllowed
            && $precisionAllowed
            && $qualityAllowed;

        $allowStrong = !$degraded
            && $confidence >= $strongThreshold
            && $modeAllowed
            && $precisionAllowed
            && $qualityAllowed
            && $coreCount >= $coreMin;

        $allowPreciseWording = !$degraded
            && $confidence >= $preciseThreshold
            && $modeAllowed
            && $precisionAllowed;

        return [
            'allow_high_confidence_badge' => $allowHigh,
            'allow_strong_evidence_badge' => $allowStrong,
            'allow_precise_wording' => $allowPreciseWording,
        ];
    }

    private function confidenceTier(float $confidence, bool $degraded): string
    {
        if ($degraded) {
            return 'low';
        }
        if ($confidence >= 0.8) {
            return 'high';
        }
        if ($confidence >= 0.6) {
            return 'medium';
        }
        return 'low';
    }
}
