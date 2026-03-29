<?php

namespace App\Services;

class DefaultWesternCompatibilityEngine implements WesternCompatibilityEngine
{
    public function natalMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        $adapter = $this->astroAdapter();
        $a = $adapter->extractSigns($chartA, $sunA);
        $b = $adapter->extractSigns($chartB, $sunB);

        $sunA = (string) ($a['sun_sign'] ?? $sunA);
        $sunB = (string) ($b['sun_sign'] ?? $sunB);
        $moonA = (string) ($a['moon_sign'] ?? '');
        $moonB = (string) ($b['moon_sign'] ?? '');
        $ascA = (string) ($a['asc_sign'] ?? '');
        $ascB = (string) ($b['asc_sign'] ?? '');

        $directionSync = $this->constellationScore($sunA, $sunB);
        $emotionSync = ($moonA !== '' && $moonB !== '') ? $this->constellationScore($moonA, $moonB) : 60.0;
        $expressionSync = ($ascA !== '' && $ascB !== '') ? $this->constellationScore($ascA, $ascB) : 60.0;

        $hasMoon = $moonA !== '' && $moonB !== '';
        $hasAsc = $ascA !== '' && $ascB !== '';
        $completenessLevel = ($hasMoon ? 1 : 0) + ($hasAsc ? 1 : 0);

        return [
            'sun_a' => $sunA,
            'sun_b' => $sunB,
            'moon_a' => $moonA,
            'moon_b' => $moonB,
            'asc_a' => $ascA,
            'asc_b' => $ascB,
            'emotion_sync' => $emotionSync,
            'expression_sync' => $expressionSync,
            'direction_sync' => $directionSync,
            'has_moon' => $hasMoon,
            'has_asc' => $hasAsc,
            'completeness_level' => $completenessLevel,
            'source' => 'default_v1',
        ];
    }

    public function pairMetrics(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        $adapter = $this->astroAdapter();
        $a = $adapter->extractSigns($chartA, $sunA);
        $b = $adapter->extractSigns($chartB, $sunB);

        $sunA = (string) ($a['sun_sign'] ?? $sunA);
        $sunB = (string) ($b['sun_sign'] ?? $sunB);
        $moonA = (string) ($a['moon_sign'] ?? '');
        $moonB = (string) ($b['moon_sign'] ?? '');
        $ascA = (string) ($a['asc_sign'] ?? '');
        $ascB = (string) ($b['asc_sign'] ?? '');

        $sunMoonAB = ($sunA !== '' && $moonB !== '') ? $this->constellationScore($sunA, $moonB) : 60.0;
        $sunMoonBA = ($sunB !== '' && $moonA !== '') ? $this->constellationScore($sunB, $moonA) : 60.0;
        $sunMoonAvg = ($sunMoonAB + $sunMoonBA) / 2.0;
        $ascScore = ($ascA !== '' && $ascB !== '') ? $this->constellationScore($ascA, $ascB) : 60.0;
        $emotionScore = ($moonA !== '' && $moonB !== '') ? $this->constellationScore($moonA, $moonB) : 60.0;

        $hasSun = $sunA !== '' && $sunB !== '';
        $hasMoon = $moonA !== '' && $moonB !== '';
        $hasAsc = $ascA !== '' && $ascB !== '';
        $componentCount = ($hasSun ? 1 : 0) + ($hasMoon ? 1 : 0) + ($hasAsc ? 1 : 0);
        $fullData = $hasSun && $hasMoon && $hasAsc;

        return [
            'sun_a' => $sunA,
            'sun_b' => $sunB,
            'moon_a' => $moonA,
            'moon_b' => $moonB,
            'asc_a' => $ascA,
            'asc_b' => $ascB,
            'sun_moon_ab' => $sunMoonAB,
            'sun_moon_ba' => $sunMoonBA,
            'sun_moon_avg' => $sunMoonAvg,
            'asc_score' => $ascScore,
            'emotion_score' => $emotionScore,
            'has_sun' => $hasSun,
            'has_moon' => $hasMoon,
            'has_asc' => $hasAsc,
            'component_count' => $componentCount,
            'full_data' => $fullData,
            'source' => 'default_v1',
        ];
    }

    private function constellationScore(string $a, string $b): float
    {
        $elements = (array) config('match_rules.constellation.elements', []);
        if ($a === '' || $b === '' || !isset($elements[$a]) || !isset($elements[$b])) {
            return 60.0;
        }
        $ea = (string) $elements[$a];
        $eb = (string) $elements[$b];
        $same = $ea === $eb;
        $complement = in_array([$ea, $eb], [
            ['fire', 'air'], ['air', 'fire'], ['earth', 'water'], ['water', 'earth'],
        ], true);
        $score = $same
            ? (float) config('match_rules.constellation.score_same_element', 85)
            : ($complement
                ? (float) config('match_rules.constellation.score_complement', 75)
                : (float) config('match_rules.constellation.score_normal', 60));
        if ($a === $b) {
            $score += (float) config('match_rules.constellation.same_sign_bonus', 5);
        }
        return max(0.0, min(100.0, $score));
    }

    private function astroAdapter(): AstroEngineAdapter
    {
        $name = strtolower(trim((string) config('matching.astro_engine_adapter', 'default')));
        if ($name === 'standard') {
            /** @var AstroEngineAdapter $svc */
            $svc = app(StandardAstroEngineAdapter::class);
            return $svc;
        }
        /** @var AstroEngineAdapter $svc */
        $svc = app(DefaultAstroEngineAdapter::class);
        return $svc;
    }
}
