<?php

namespace App\Services;

class BaziFeatureExtractor
{
    /**
     * @return array{
     *   available:bool,
     *   structure_score:float,
     *   relationship_score:float,
     *   timing_score:float,
     *   confidence:float,
     *   evidence_tags:array<int,string>,
     *   evidence:array<string,mixed>,
     *   degraded:bool,
     *   degrade_reason:string
     * }
     */
    public function extractPairFeatures(string $baziA, string $baziB, mixed $chartA, mixed $chartB): array
    {
        $wuA = $this->extractWuXing($chartA);
        $wuB = $this->extractWuXing($chartB);
        if (empty($wuA) || empty($wuB)) {
            return [
                'available' => false,
                'structure_score' => 0.0,
                'relationship_score' => 0.0,
                'timing_score' => 0.0,
                'confidence' => 0.0,
                'evidence_tags' => [],
                'evidence' => [],
                'degraded' => true,
                'degrade_reason' => 'missing_wu_xing',
            ];
        }

        $structure = $this->computeStructureScore($wuA, $wuB);
        $relationship = $this->computeRelationshipScore($baziA, $baziB);
        $timing = $this->computeTimingScore($chartA, $chartB);

        $confidence = 0.92;
        if ($timing['degraded']) {
            $confidence -= 0.12;
        }
        if ($relationship['degraded']) {
            $confidence -= 0.10;
        }
        $confidence = max(0.55, min(1.0, $confidence));

        $tags = array_values(array_unique(array_merge(
            ['bazi_feature_extractor_v1', 'wu_xing_structure'],
            $structure['tags'],
            $relationship['tags'],
            $timing['tags']
        )));

        return [
            'available' => true,
            'structure_score' => $structure['score'],
            'relationship_score' => $relationship['score'],
            'timing_score' => $timing['score'],
            'confidence' => $confidence,
            'evidence_tags' => $tags,
            'evidence' => [
                'wu_xing' => $structure['evidence'],
                'relationship' => $relationship['evidence'],
                'timing' => $timing['evidence'],
            ],
            'degraded' => $timing['degraded'] || $relationship['degraded'],
            'degrade_reason' => $timing['degraded'] ? 'partial_timing_features' : ($relationship['degraded'] ? 'missing_branch_relation' : ''),
        ];
    }

    /**
     * @param array<string,int> $wuA
     * @param array<string,int> $wuB
     * @return array{score:float,evidence:array<string,mixed>,tags:array<int,string>}
     */
    private function computeStructureScore(array $wuA, array $wuB): array
    {
        $keys = ['木', '火', '土', '金', '水'];
        $sumA = max(1, array_sum(array_map(fn ($k) => (int) ($wuA[$k] ?? 0), $keys)));
        $sumB = max(1, array_sum(array_map(fn ($k) => (int) ($wuB[$k] ?? 0), $keys)));
        $dist = 0.0;
        $ratiosA = [];
        $ratiosB = [];
        foreach ($keys as $k) {
            $va = ((int) ($wuA[$k] ?? 0)) / $sumA;
            $vb = ((int) ($wuB[$k] ?? 0)) / $sumB;
            $dist += abs($va - $vb);
            $ratiosA[$k] = $va;
            $ratiosB[$k] = $vb;
        }

        $complement = max(0.0, min(1.0, 1.0 - ($dist / 2.0)));
        $balanceA = 1.0 - (max($ratiosA) - min($ratiosA));
        $balanceB = 1.0 - (max($ratiosB) - min($ratiosB));
        $balanceAvg = max(0.0, min(1.0, ($balanceA + $balanceB) / 2.0));
        $score = (0.6 * $complement * 100.0) + (0.4 * $balanceAvg * 100.0);

        $dominantA = array_search(max($wuA), $wuA, true);
        $dominantB = array_search(max($wuB), $wuB, true);
        $tags = ['wu_xing_complement'];
        if ($dominantA !== false && $dominantA === $dominantB) {
            $tags[] = 'wu_xing_same_dominant';
        } else {
            $tags[] = 'wu_xing_dominant_complement';
        }

        return [
            'score' => max(0.0, min(100.0, $score)),
            'evidence' => [
                'wu_xing_a' => $wuA,
                'wu_xing_b' => $wuB,
                'wu_xing_distance' => round($dist, 4),
                'wu_xing_complement' => round($complement, 4),
                'wu_xing_balance_a' => round($balanceA, 4),
                'wu_xing_balance_b' => round($balanceB, 4),
                'wu_xing_balance_avg' => round($balanceAvg, 4),
            ],
            'tags' => $tags,
        ];
    }

    /**
     * @return array{score:float,evidence:array<string,mixed>,tags:array<int,string>,degraded:bool}
     */
    private function computeRelationshipScore(string $baziA, string $baziB): array
    {
        $dayBranchA = $this->extractDayBranch($baziA);
        $dayBranchB = $this->extractDayBranch($baziB);
        $yearBranchA = $this->extractYearBranch($baziA);
        $yearBranchB = $this->extractYearBranch($baziB);

        $branchA = $dayBranchA ?: $yearBranchA;
        $branchB = $dayBranchB ?: $yearBranchB;

        if ($branchA === '' || $branchB === '') {
            return [
                'score' => 60.0,
                'evidence' => [
                    'day_branch_a' => $dayBranchA,
                    'day_branch_b' => $dayBranchB,
                    'year_branch_a' => $yearBranchA,
                    'year_branch_b' => $yearBranchB,
                    'relation_type' => 'unknown',
                ],
                'tags' => ['bazi_branch_relation_unknown'],
                'degraded' => true,
            ];
        }

        $relation = $this->branchRelation($branchA, $branchB);
        $scores = (array) config('match_rules.bazi.relation_scores', []);
        $score = (float) ($scores[$relation] ?? 60.0);
        $tags = match ($relation) {
            'liuhe' => ['bazi_branch_liuhe'],
            'sanhe' => ['bazi_branch_sanhe'],
            'same' => ['bazi_branch_same'],
            'chong' => ['bazi_branch_chong'],
            'xing' => ['bazi_branch_xing'],
            'hai' => ['bazi_branch_hai'],
            default => ['bazi_branch_normal'],
        };

        return [
            'score' => max(0.0, min(100.0, $score)),
            'evidence' => [
                'branch_a' => $branchA,
                'branch_b' => $branchB,
                'day_branch_a' => $dayBranchA,
                'day_branch_b' => $dayBranchB,
                'year_branch_a' => $yearBranchA,
                'year_branch_b' => $yearBranchB,
                'relation_type' => $relation,
            ],
            'tags' => $tags,
            'degraded' => false,
        ];
    }

    /**
     * @return array{score:float,evidence:array<string,mixed>,tags:array<int,string>,degraded:bool}
     */
    private function computeTimingScore(mixed $chartA, mixed $chartB): array
    {
        $yearsA = $this->extractYearSet($chartA, ['liu_nian', 'da_yun']);
        $yearsB = $this->extractYearSet($chartB, ['liu_nian', 'da_yun']);

        if (empty($yearsA) || empty($yearsB)) {
            return [
                'score' => 60.0,
                'evidence' => [
                    'years_a_count' => count($yearsA),
                    'years_b_count' => count($yearsB),
                    'overlap_years' => [],
                ],
                'tags' => ['bazi_timing_partial'],
                'degraded' => true,
            ];
        }

        $inter = array_values(array_intersect($yearsA, $yearsB));
        $union = array_values(array_unique(array_merge($yearsA, $yearsB)));
        $jaccard = count($union) > 0 ? (count($inter) / count($union)) : 0.0;
        $score = 55.0 + (45.0 * $jaccard);

        return [
            'score' => max(0.0, min(100.0, $score)),
            'evidence' => [
                'years_a_count' => count($yearsA),
                'years_b_count' => count($yearsB),
                'overlap_count' => count($inter),
                'overlap_ratio' => round($jaccard, 4),
                'overlap_years' => array_slice($inter, 0, 12),
            ],
            'tags' => $jaccard >= 0.30 ? ['bazi_timing_sync_high'] : ['bazi_timing_sync_low'],
            'degraded' => false,
        ];
    }

    private function extractDayBranch(string $bazi): string
    {
        if (preg_match('/([子丑寅卯辰巳午未申酉戌亥])日/u', $bazi, $m) === 1) {
            return (string) ($m[1] ?? '');
        }
        return '';
    }

    private function extractYearBranch(string $bazi): string
    {
        if (preg_match('/([子丑寅卯辰巳午未申酉戌亥])年/u', $bazi, $m) === 1) {
            return (string) ($m[1] ?? '');
        }
        return '';
    }

    private function branchRelation(string $a, string $b): string
    {
        if ($a === $b) {
            return 'same';
        }

        $pairs = [
            'chong' => (array) config('match_rules.zodiac.chong', []),
            'xing' => (array) config('match_rules.zodiac.xing', []),
            'hai' => (array) config('match_rules.zodiac.hai', []),
            'liuhe' => (array) config('match_rules.zodiac.liuhe', []),
            'sanhe' => (array) config('match_rules.zodiac.sanhe', []),
        ];

        foreach (['chong', 'xing', 'hai', 'liuhe', 'sanhe'] as $type) {
            foreach ($pairs[$type] as $pair) {
                if (!is_array($pair) || count($pair) < 2) {
                    continue;
                }
                [$x, $y] = $pair;
                if (($a === $x && $b === $y) || ($a === $y && $b === $x)) {
                    return $type;
                }
            }
        }

        return 'normal';
    }

    /**
     * @return array<string,int>
     */
    private function extractWuXing(mixed $chart): array
    {
        if (!is_array($chart)) {
            return [];
        }
        $raw = $chart['wu_xing'] ?? null;
        if (!is_array($raw)) {
            return [];
        }
        $normalized = [];
        foreach (['木', '火', '土', '金', '水'] as $k) {
            $normalized[$k] = (int) ($raw[$k] ?? 0);
        }
        return $normalized;
    }

    /**
     * @param array<int,string> $keys
     * @return array<int,int>
     */
    private function extractYearSet(mixed $chart, array $keys): array
    {
        if (!is_array($chart)) {
            return [];
        }

        $years = [];
        foreach ($keys as $k) {
            $years = array_merge($years, $this->extractYearValues($chart[$k] ?? null));
        }
        $years = array_values(array_unique(array_map('intval', $years)));
        sort($years);

        return array_values(array_filter($years, fn ($y) => $y >= 1900 && $y <= 2100));
    }

    /**
     * @return array<int,int>
     */
    private function extractYearValues(mixed $data): array
    {
        $years = [];
        if (is_int($data)) {
            return [$data];
        }
        if (is_string($data)) {
            if (preg_match_all('/\b(19|20)\d{2}\b/', $data, $m) === 1 || (isset($m[0]) && count($m[0]) > 0)) {
                foreach ((array) ($m[0] ?? []) as $v) {
                    $years[] = (int) $v;
                }
            }
            return $years;
        }
        if (is_array($data)) {
            foreach ($data as $k => $v) {
                if (is_string($k) && preg_match('/^(19|20)\d{2}$/', $k) === 1) {
                    $years[] = (int) $k;
                }
                $years = array_merge($years, $this->extractYearValues($v));
            }
        }

        return $years;
    }
}

