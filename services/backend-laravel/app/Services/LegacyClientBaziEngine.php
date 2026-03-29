<?php

namespace App\Services;

class LegacyClientBaziEngine implements BaziEngine
{
    /**
     * @param array<string,mixed> $payload
     */
    public function canonicalize(array $payload): array
    {
        $birthTime = trim((string) ($payload['birth_time'] ?? ''));
        $hasLat = array_key_exists('birth_lat', $payload) && $payload['birth_lat'] !== null;
        $hasLng = array_key_exists('birth_lng', $payload) && $payload['birth_lng'] !== null;

        $confidence = 0.72;
        $notes = [];
        if ($birthTime === '') {
            $confidence = min($confidence, (float) config('confidence_policy.astro.date_only.confidence_cap', 0.55));
            $notes[] = 'confidence_policy:date_only';
        }
        if (!$hasLat || !$hasLng) {
            $confidence = min($confidence, (float) config('confidence_policy.astro.no_birth_location.confidence_cap', 0.65));
            $notes[] = 'confidence_policy:no_birth_location';
        }

        $notes[] = 'canonical_source:legacy_client';
        $notes[] = 'precision:legacy_estimate';

        return [
            'sun_sign' => trim((string) ($payload['sun_sign'] ?? '')),
            'moon_sign' => $this->nullable($payload['moon_sign'] ?? null),
            'asc_sign' => $this->nullable($payload['asc_sign'] ?? null),
            'bazi' => $this->nullable($payload['bazi'] ?? null),
            'true_solar_time' => $this->nullable($payload['true_solar_time'] ?? null),
            'da_yun' => is_array($payload['da_yun'] ?? null) ? array_values($payload['da_yun']) : [],
            'liu_nian' => is_array($payload['liu_nian'] ?? null) ? array_values($payload['liu_nian']) : [],
            'wu_xing' => is_array($payload['wu_xing'] ?? null) ? (array) $payload['wu_xing'] : [],
            'notes' => $notes,
            'accuracy' => (string) config('astro_canonical.labels.legacy_client', 'legacy_estimate'),
            'confidence' => max(0.0, min(1.0, $confidence)),
        ];
    }

    private function nullable(mixed $value): ?string
    {
        $v = trim((string) ($value ?? ''));
        return $v === '' ? null : $v;
    }
}

