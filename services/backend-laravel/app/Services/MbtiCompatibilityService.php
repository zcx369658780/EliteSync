<?php

namespace App\Services;

class MbtiCompatibilityService
{
    /**
     * @return array{
     *  score:int,confidence:float,highlight:string,risk:string,
     *  reason_short:string,reason_detail:string,risk_detail:string,
     *  evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *  degraded:bool,degrade_reason:string,verdict:string
     * }
     */
    public function score(string $mbtiA, string $mbtiB): array
    {
        $a = strtoupper(trim($mbtiA));
        $b = strtoupper(trim($mbtiB));
        $cfg = (array) config('match_rules.mbti', []);
        $weights = (array) ($cfg['weights'] ?? []);
        $missingTpl = (array) (($cfg['templates'] ?? [])['missing'] ?? []);

        if (!$this->isMbti($a) || !$this->isMbti($b)) {
            return [
                'score' => 55,
                'confidence' => 0.55,
                'highlight' => (string) ($missingTpl['highlight'] ?? 'MBTI 数据不完整，采用中性估计'),
                'risk' => (string) ($missingTpl['risk'] ?? '建议补全 MBTI 结果以提高沟通适配判断可靠性'),
                'reason_short' => (string) ($missingTpl['short'] ?? 'MBTI 数据不完整，当前仅作中性参考。'),
                'reason_detail' => (string) ($missingTpl['detail'] ?? '当前缺少完整 MBTI 结果，系统只能按简化规则估算沟通与决策节奏，不建议将该项作为强结论。'),
                'risk_detail' => (string) ($missingTpl['risk_detail'] ?? '建议先完成 MBTI 测试，再结合人格画像与玄学模块综合判断。'),
                'evidence_tags' => ['mbti_lite_low_confidence', 'missing_mbti'],
                'evidence' => [
                    'type_a' => $a,
                    'type_b' => $b,
                ],
                'degraded' => true,
                'degrade_reason' => 'missing_mbti',
                'verdict' => 'medium',
            ];
        }

        $dim = $this->dimensionScore($a, $b);
        $stack = $this->stackScore($a, $b);
        $lifestyle = $this->lifestyleAdjustment($a, $b);

        $raw = ((float) ($weights['base'] ?? 45))
            + ($dim['score'] * (float) ($weights['dimension_factor'] ?? 0.55))
            + ($stack['score'] * (float) ($weights['stack_factor'] ?? 0.35))
            + ($lifestyle['score'] * (float) ($weights['lifestyle_factor'] ?? 0.10));
        $score = (int) round(max(0.0, min(100.0, $raw)));
        $verdict = $score >= 80 ? 'strong' : ($score >= 60 ? 'medium' : 'weak');

        $reasonShort = $this->composeShortReason($a, $b, $dim, $score);
        $reasonDetail = $this->composeDetailReason($a, $b, $dim, $stack, $lifestyle);
        $risk = $this->composeRisk($dim, $lifestyle, $stack);
        $riskDetail = $this->composeRiskDetail($a, $b, $dim, $lifestyle, $stack);

        $tags = [];
        foreach ($dim['dims'] as $axis => $row) {
            $tags[] = "mbti_axis_{$axis}_".($row['same'] ? 'same' : 'diff');
        }
        if ((bool) ($stack['dominant_aux_pair'] ?? false)) {
            $tags[] = 'mbti_stack_complement';
        }
        if ((bool) ($stack['strong_strong_conflict'] ?? false)) {
            $tags[] = 'mbti_strong_strong_risk';
        }
        if ((bool) ($lifestyle['jp_conflict'] ?? false)) {
            $tags[] = 'mbti_jp_lifestyle_risk';
        }

        return [
            'score' => $score,
            'confidence' => 0.62, // lite quiz, confidence should remain moderate.
            'highlight' => $reasonShort,
            'risk' => $risk,
            'reason_short' => $reasonShort,
            'reason_detail' => $reasonDetail,
            'risk_detail' => $riskDetail,
            'evidence_tags' => array_values(array_unique($tags)),
            'evidence' => [
                'type_a' => $a,
                'type_b' => $b,
                'dimensions' => $dim['dims'],
                'dimension_score' => $dim['score'],
                'stack_score' => $stack['score'],
                'stack_flags' => [
                    'dominant_same' => $stack['dominant_same'],
                    'dominant_aux_pair' => $stack['dominant_aux_pair'],
                    'strong_strong_conflict' => $stack['strong_strong_conflict'],
                ],
                'lifestyle_score' => $lifestyle['score'],
                'lifestyle_flags' => [
                    'jp_conflict' => $lifestyle['jp_conflict'],
                    'tf_conflict' => $lifestyle['tf_conflict'],
                ],
            ],
            'degraded' => false,
            'degrade_reason' => '',
            'verdict' => $verdict,
        ];
    }

    /**
     * @return array{
     *  score:int,
     *  dims:array<string,array{same:bool,score:int,note:string}>
     * }
     */
    private function dimensionScore(string $a, string $b): array
    {
        $weights = (array) config('match_rules.mbti.weights', []);
        $w = (array) ($weights['dimension'] ?? []);
        $dims = [];
        $sum = 0;

        $sameEI = $a[0] === $b[0];
        $dims['ei'] = [
            'same' => $sameEI,
            'score' => $sameEI ? (int) ($w['same_ei'] ?? 6) : (int) ($w['diff_ei'] ?? 4),
            'note' => $sameEI
                ? '能量来源接近，社交/独处节奏更易同频'
                : '能量来源互补，需协商社交与恢复节奏',
        ];
        $sum += $dims['ei']['score'];

        $sameSN = $a[1] === $b[1];
        $dims['sn'] = [
            'same' => $sameSN,
            'score' => $sameSN ? (int) ($w['same_sn'] ?? 8) : (int) ($w['diff_sn'] ?? 3),
            'note' => $sameSN
                ? '信息处理语境接近，沟通成本较低'
                : '信息关注点不同，互补但易出现“现实/可能性”错位',
        ];
        $sum += $dims['sn']['score'];

        $sameTF = $a[2] === $b[2];
        $dims['tf'] = [
            'same' => $sameTF,
            'score' => $sameTF ? (int) ($w['same_tf'] ?? 8) : (int) ($w['diff_tf'] ?? 2),
            'note' => $sameTF
                ? '决策风格更一致，冲突处理路径更清晰'
                : '决策风格互补但易误读，需明确表达偏好',
        ];
        $sum += $dims['tf']['score'];

        $sameJP = $a[3] === $b[3];
        $dims['jp'] = [
            'same' => $sameJP,
            'score' => $sameJP ? (int) ($w['same_jp'] ?? 8) : (int) ($w['diff_jp'] ?? 4),
            'note' => $sameJP
                ? '生活节奏和执行风格更稳定'
                : '推进节奏互补但长期执行需提前对齐',
        ];
        $sum += $dims['jp']['score'];

        return [
            'score' => $sum,
            'dims' => $dims,
        ];
    }

    /**
     * Lightweight stack compatibility:
     * - dominant same: +4
     * - dominant<->aux pair: +6
     * - strong-strong (TJ leadership) collision: -6
     *
     * @return array{score:int,dominant_same:bool,dominant_aux_pair:bool,strong_strong_conflict:bool}
     */
    private function stackScore(string $a, string $b): array
    {
        $weights = (array) config('match_rules.mbti.weights', []);
        $w = (array) ($weights['stack'] ?? []);
        $stackA = $this->functionStack($a);
        $stackB = $this->functionStack($b);

        $score = 0;
        $dominantSame = $stackA['dom'] === $stackB['dom'];
        $dominantAuxPair = ($stackA['dom'] === $stackB['aux']) || ($stackB['dom'] === $stackA['aux']);
        $strongStrongConflict = $this->isStrongDecider($a) && $this->isStrongDecider($b);

        if ($dominantSame) {
            $score += (int) ($w['dominant_same'] ?? 4);
        }
        if ($dominantAuxPair) {
            $score += (int) ($w['dominant_aux_pair'] ?? 6);
        }
        if ($strongStrongConflict) {
            $score += (int) ($w['strong_strong_conflict'] ?? -6);
        }

        return [
            'score' => $score,
            'dominant_same' => $dominantSame,
            'dominant_aux_pair' => $dominantAuxPair,
            'strong_strong_conflict' => $strongStrongConflict,
        ];
    }

    /**
     * @return array{score:int,jp_conflict:bool,tf_conflict:bool}
     */
    private function lifestyleAdjustment(string $a, string $b): array
    {
        $weights = (array) config('match_rules.mbti.weights', []);
        $w = (array) ($weights['lifestyle'] ?? []);
        $score = 0;
        $jpConflict = false;
        $tfConflict = false;

        if ($a[3] !== $b[3]) {
            // J/P difference has complement value but long-term rhythm friction.
            $score += (int) ($w['jp_conflict'] ?? -3);
            $jpConflict = true;
        }

        if ($a[2] !== $b[2] && $this->isStrongDecider($a) && $this->isFeelingLed($b)) {
            $score += (int) ($w['tf_conflict'] ?? -3);
            $tfConflict = true;
        } elseif ($a[2] !== $b[2] && $this->isStrongDecider($b) && $this->isFeelingLed($a)) {
            $score += (int) ($w['tf_conflict'] ?? -3);
            $tfConflict = true;
        }

        return [
            'score' => $score,
            'jp_conflict' => $jpConflict,
            'tf_conflict' => $tfConflict,
        ];
    }

    /**
     * @return array{dom:string,aux:string}
     */
    private function functionStack(string $type): array
    {
        // Lightweight mapping (dominant/auxiliary only) for 16 types.
        $map = [
            'INTJ' => ['dom' => 'Ni', 'aux' => 'Te'],
            'INTP' => ['dom' => 'Ti', 'aux' => 'Ne'],
            'ENTJ' => ['dom' => 'Te', 'aux' => 'Ni'],
            'ENTP' => ['dom' => 'Ne', 'aux' => 'Ti'],
            'INFJ' => ['dom' => 'Ni', 'aux' => 'Fe'],
            'INFP' => ['dom' => 'Fi', 'aux' => 'Ne'],
            'ENFJ' => ['dom' => 'Fe', 'aux' => 'Ni'],
            'ENFP' => ['dom' => 'Ne', 'aux' => 'Fi'],
            'ISTJ' => ['dom' => 'Si', 'aux' => 'Te'],
            'ISFJ' => ['dom' => 'Si', 'aux' => 'Fe'],
            'ESTJ' => ['dom' => 'Te', 'aux' => 'Si'],
            'ESFJ' => ['dom' => 'Fe', 'aux' => 'Si'],
            'ISTP' => ['dom' => 'Ti', 'aux' => 'Se'],
            'ISFP' => ['dom' => 'Fi', 'aux' => 'Se'],
            'ESTP' => ['dom' => 'Se', 'aux' => 'Ti'],
            'ESFP' => ['dom' => 'Se', 'aux' => 'Fi'],
        ];
        return $map[$type] ?? ['dom' => 'NA', 'aux' => 'NA'];
    }

    private function composeShortReason(string $a, string $b, array $dim, int $score): string
    {
        $sameCount = 0;
        foreach ($dim['dims'] as $row) {
            if ((bool) ($row['same'] ?? false)) {
                $sameCount++;
            }
        }
        if ($score >= 80) {
            return "MBTI 沟通适配度较高（{$a} × {$b}），互动节奏更容易形成默契。";
        }
        if ($score >= 60) {
            return "MBTI 处于中等匹配（{$a} × {$b}），具备互补空间但需要主动对齐。";
        }
        return "MBTI 差异较明显（{$a} × {$b}），建议提前约定沟通与决策节奏（同维度{$sameCount}/4）。";
    }

    private function composeDetailReason(string $a, string $b, array $dim, array $stack, array $lifestyle): string
    {
        $notes = [];
        foreach ($dim['dims'] as $row) {
            $note = trim((string) ($row['note'] ?? ''));
            if ($note !== '') {
                $notes[] = $note;
            }
        }
        if ((bool) ($stack['dominant_aux_pair'] ?? false)) {
            $notes[] = '认知功能上存在“主导-辅助”互补，通常有助于理解与执行分工。';
        }
        if ((bool) ($lifestyle['jp_conflict'] ?? false)) {
            $notes[] = '长期生活节奏（计划性与弹性）差异较大时，需要明确执行规则。';
        }
        return implode('；', array_slice($notes, 0, 4));
    }

    private function composeRisk(array $dim, array $lifestyle, array $stack): string
    {
        if ((bool) ($stack['strong_strong_conflict'] ?? false)) {
            return '双方都偏强主导风格，冲突场景可能出现“强碰强”';
        }
        if ((bool) ($lifestyle['jp_conflict'] ?? false) || (bool) ($lifestyle['tf_conflict'] ?? false)) {
            return '决策或执行节奏存在差异，磨合期需更高沟通频率';
        }
        $sameCount = 0;
        foreach ($dim['dims'] as $row) {
            if ((bool) ($row['same'] ?? false)) {
                $sameCount++;
            }
        }
        return $sameCount <= 1 ? '维度差异较多，建议先建立冲突处理约定' : '';
    }

    private function composeRiskDetail(string $a, string $b, array $dim, array $lifestyle, array $stack): string
    {
        if ((bool) ($stack['strong_strong_conflict'] ?? false)) {
            return "类型组合 {$a} × {$b} 在主导风格上都偏推进与控制，若边界不清晰，容易在决策权上反复拉扯。";
        }
        if ((bool) ($lifestyle['tf_conflict'] ?? false)) {
            return 'T/F 决策风格差异叠加强主导倾向时，常见风险是“逻辑正确”与“情绪被理解”无法同时满足。';
        }
        if ((bool) ($lifestyle['jp_conflict'] ?? false)) {
            return 'J/P 执行节奏差异在长期关系中会放大，建议提前约定计划、复盘和变更机制。';
        }
        return '';
    }

    private function isStrongDecider(string $type): bool
    {
        return in_array($type, ['ENTJ', 'ESTJ', 'INTJ', 'ISTJ'], true);
    }

    private function isFeelingLed(string $type): bool
    {
        return in_array($type, ['ENFJ', 'ESFJ', 'INFJ', 'ISFJ', 'ENFP', 'ESFP', 'INFP', 'ISFP'], true);
    }

    private function isMbti(string $value): bool
    {
        return (bool) preg_match('/^[EI][NS][TF][JP]$/', $value);
    }
}
