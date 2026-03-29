<?php

namespace App\Services;

class PairChartFeatureExtractor
{
    /**
     * @param array<string,float|int|bool|string> $metrics
     * @param array<string,float> $weights
     * @return array{
     *   score:int,
     *   confidence:float,
     *   degraded:bool,
     *   degrade_reason:string,
     *   features:array<int,array<string,mixed>>,
     *   top_highlights:array<int,string>,
     *   top_risks:array<int,string>
     * }
     */
    public function build(array $metrics, array $weights): array
    {
        $sunMoon = (float) ($metrics['sun_moon_harmony'] ?? 60.0);
        $asc = (float) ($metrics['asc_interaction'] ?? 60.0);
        $emotion = (float) ($metrics['emotion_rhythm'] ?? 60.0);
        $long = (float) ($metrics['long_term_stability'] ?? 60.0);
        $componentCount = (int) ($metrics['component_count'] ?? 0);

        $wSunMoon = (float) ($weights['sun_moon_harmony'] ?? 0.35);
        $wAsc = (float) ($weights['asc_interaction'] ?? 0.20);
        $wEmotion = (float) ($weights['emotion_rhythm'] ?? 0.25);
        $wLong = (float) ($weights['long_term_stability'] ?? 0.20);
        $norm = max(0.0001, $wSunMoon + $wAsc + $wEmotion + $wLong);
        $wSunMoon /= $norm;
        $wAsc /= $norm;
        $wEmotion /= $norm;
        $wLong /= $norm;

        $raw = ($wSunMoon * $sunMoon) + ($wAsc * $asc) + ($wEmotion * $emotion) + ($wLong * $long);
        $score = (int) round(max(0.0, min(100.0, $raw)));

        $full = (bool) ($metrics['full_data'] ?? false);
        $partial = $componentCount >= 2;
        $confidence = $full ? 0.92 : ($partial ? 0.74 : 0.52);
        $degraded = !$full;
        $degradeReason = $full ? '' : ($partial ? 'partial_pair_chart' : 'sun_only_estimation');

        $features = [
            $this->featureRow(
                key: 'sun_moon_harmony',
                label: '日月互动',
                score: $sunMoon,
                weight: $wSunMoon,
                tags: ['sun_moon_harmony'],
                evidence: [
                    'sun_moon_ab' => (float) ($metrics['sun_moon_ab'] ?? $sunMoon),
                    'sun_moon_ba' => (float) ($metrics['sun_moon_ba'] ?? $sunMoon),
                ]
            ),
            $this->featureRow(
                key: 'asc_interaction',
                label: '上升互动',
                score: $asc,
                weight: $wAsc,
                tags: ['asc_style_match'],
                evidence: [
                    'asc_score' => $asc,
                ]
            ),
            $this->featureRow(
                key: 'emotion_rhythm',
                label: '情绪节奏',
                score: $emotion,
                weight: $wEmotion,
                tags: ['emotion_rhythm'],
                evidence: [
                    'emotion_rhythm_score' => $emotion,
                ]
            ),
            $this->featureRow(
                key: 'long_term_stability',
                label: '长期稳定',
                score: $long,
                weight: $wLong,
                tags: ['long_term_stability'],
                evidence: [
                    'bazi_bridge' => $long,
                ]
            ),
        ];

        usort($features, function (array $a, array $b): int {
            return ((float) ($b['contribution'] ?? 0.0)) <=> ((float) ($a['contribution'] ?? 0.0));
        });

        $topHighlights = [];
        $topRisks = [];
        foreach ($features as $f) {
            $label = (string) ($f['label'] ?? '');
            $fScore = (int) round((float) ($f['score'] ?? 0.0));
            if ($fScore >= 70) {
                $topHighlights[] = "{$label}{$fScore}分";
            }
            if ($fScore < 60) {
                $topRisks[] = "{$label}{$fScore}分";
            }
        }

        return [
            'score' => $score,
            'confidence' => $confidence,
            'degraded' => $degraded,
            'degrade_reason' => $degradeReason,
            'features' => $features,
            'top_highlights' => array_slice($topHighlights, 0, 3),
            'top_risks' => array_slice($topRisks, 0, 3),
        ];
    }

    /**
     * @param array<int,string> $tags
     * @param array<string,mixed> $evidence
     * @return array<string,mixed>
     */
    private function featureRow(string $key, string $label, float $score, float $weight, array $tags, array $evidence): array
    {
        $score = max(0.0, min(100.0, $score));
        $weight = max(0.0, min(1.0, $weight));
        return [
            'key' => $key,
            'label' => $label,
            'score' => (int) round($score),
            'weight' => round($weight, 4),
            'contribution' => round($score * $weight, 2),
            'evidence_tags' => array_values(array_unique($tags)),
            'evidence' => $evidence,
        ];
    }
}

