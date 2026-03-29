<?php

namespace App\Services;

use com\nlf\calendar\Solar;

class LegacyInputWesternNatalEngine implements WesternNatalEngine
{
    /**
     * @param array<string,mixed> $payload
     */
    public function compute(array $payload): array
    {
        $birthday = trim((string) ($payload['birthday'] ?? ''));
        $sunSign = trim((string) ($payload['sun_sign'] ?? ''));
        if ($sunSign === '' && preg_match('/^(\d{4})-(\d{2})-(\d{2})$/', $birthday, $m)) {
            try {
                $sunSign = (string) Solar::fromYmd((int) $m[1], (int) $m[2], (int) $m[3])->getXingZuo();
            } catch (\Throwable) {
                $sunSign = '';
            }
        }
        if ($sunSign !== '' && !str_ends_with($sunSign, '座')) {
            $sunSign .= '座';
        }

        $moon = $this->nullable($payload['moon_sign'] ?? null);
        $asc = $this->nullable($payload['asc_sign'] ?? null);

        $confidence = 0.66;
        $degraded = false;
        $degradeReason = '';
        if ($moon === null || $asc === null) {
            $degraded = true;
            $degradeReason = 'missing_moon_or_asc';
            $confidence = min($confidence, (float) config('confidence_policy.astro.no_birth_location.confidence_cap', 0.65));
        }
        if (trim((string) ($payload['birth_time'] ?? '')) === '') {
            $degraded = true;
            $degradeReason = $degradeReason !== '' ? $degradeReason.'|no_birth_time' : 'no_birth_time';
            $confidence = min($confidence, (float) config('confidence_policy.astro.no_birth_time.confidence_cap', 0.70));
        }

        return [
            'sun_sign' => $sunSign,
            'moon_sign' => $moon,
            'asc_sign' => $asc,
            'engine' => 'legacy_input',
            'precision' => (string) config('western_natal.labels.legacy_input', 'legacy_estimate'),
            'confidence' => max(0.0, min(1.0, $confidence)),
            'degraded' => $degraded,
            'degrade_reason' => $degradeReason,
        ];
    }

    private function nullable(mixed $value): ?string
    {
        $v = trim((string) ($value ?? ''));
        return $v === '' ? null : $v;
    }
}

