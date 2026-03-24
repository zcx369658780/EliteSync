<?php

namespace App\Services;

class PersonalityCompatibilityService
{
    /**
     * @param array<string,int> $vectorA
     * @param array<string,int> $vectorB
     * @param array<string,float> $categoryScores
     * @return array{
     *  score:int,confidence:float,highlight:string,risk:string,
     *  reason_short:string,reason_detail:string,risk_detail:string,
     *  evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *  degraded:bool,degrade_reason:string,verdict:string
     * }
     */
    public function score(
        array $vectorA,
        array $vectorB,
        float $profileSimilarity,
        float $biQuestion,
        float $interestSimilarity,
        array $categoryScores
    ): array {
        $categoryAvg = empty($categoryScores)
            ? 0.5
            : (array_sum($categoryScores) / max(1, count($categoryScores)));

        $profilePart = $profileSimilarity * 100 * 0.35;
        $acceptPart = $biQuestion * 100 * 0.35;
        $categoryPart = $categoryAvg * 100 * 0.20;
        $interestPart = $interestSimilarity * 100 * 0.10;
        $score = (int) round($profilePart + $acceptPart + $categoryPart + $interestPart);
        $score = max(0, min(100, $score));

        $keyDims = [
            'attachment_security',
            'emotional_regulation',
            'communication_clarity',
            'conflict_repair',
            'commitment_readiness',
        ];
        $dimGaps = [];
        foreach ($keyDims as $d) {
            $va = (int) ($vectorA[$d] ?? 0);
            $vb = (int) ($vectorB[$d] ?? 0);
            if ($va === 0 && $vb === 0) {
                continue;
            }
            $dimGaps[$d] = abs($va - $vb);
        }
        $avgGap = empty($dimGaps) ? 0 : (array_sum($dimGaps) / count($dimGaps));

        $degraded = empty($vectorA) || empty($vectorB);
        $confidence = $degraded ? 0.60 : 0.90;
        $verdict = $score >= 80 ? 'strong' : ($score >= 60 ? 'medium' : 'weak');

        $highlight = $score >= 75
            ? '人格与互动偏好接近，长期磨合成本较低'
            : '人格结构存在差异，但核心互动仍具备可塑性';
        $risk = $score < 60
            ? '依恋安全感或冲突修复倾向差距偏大，需要更主动沟通'
            : '';
        $reasonShort = $score >= 75
            ? '人格与互动偏好接近，长期磨合成本较低。'
            : '人格结构有差异，但核心互动仍具可塑性。';
        $reasonDetail = $score >= 75
            ? '你们在依恋安全感、冲突修复和沟通清晰度等关键维度上更接近，长期相处中更容易形成稳定节律。'
            : '你们在部分关键维度存在差异，但并非不可调和。若能在沟通边界与冲突修复策略上主动对齐，仍有较高可塑空间。';
        $riskDetail = $score < 60
            ? '关键维度差距偏大（如依恋安全感或冲突修复倾向），建议在关系早期明确沟通规则和预期管理。'
            : '';
        $tags = [];
        if ($profileSimilarity >= 0.75) {
            $tags[] = 'profile_similarity_high';
        }
        if ($biQuestion >= 0.70) {
            $tags[] = 'bidirectional_acceptance_high';
        }
        if ($avgGap >= 25) {
            $tags[] = 'key_dimension_gap_high';
        }
        if ($degraded) {
            $tags[] = 'missing_personality_vector';
        }

        return [
            'score' => $score,
            'confidence' => $confidence,
            'highlight' => $highlight,
            'risk' => $risk,
            'reason_short' => $reasonShort,
            'reason_detail' => $reasonDetail,
            'risk_detail' => $riskDetail,
            'evidence_tags' => $tags,
            'evidence' => [
                'profile_similarity' => round($profileSimilarity, 4),
                'bidirectional_acceptance_score' => round($biQuestion, 4),
                'interest_overlap' => round($interestSimilarity, 4),
                'category_average' => round($categoryAvg, 4),
                'key_dimension_gaps' => $dimGaps,
                'average_key_dimension_gap' => round($avgGap, 2),
            ],
            'degraded' => $degraded,
            'degrade_reason' => $degraded ? 'missing_personality_vector' : '',
            'verdict' => $verdict,
        ];
    }
}
