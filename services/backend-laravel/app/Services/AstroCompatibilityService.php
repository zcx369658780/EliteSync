<?php

namespace App\Services;

class AstroCompatibilityService
{
    /**
     * @param array{zodiac_animal:string,public_zodiac_sign:string,private_bazi:string,private_natal_chart:mixed,birthday:?string} $a
     * @param array{zodiac_animal:string,public_zodiac_sign:string,private_bazi:string,private_natal_chart:mixed,birthday:?string} $b
     * @return array{
      *  bazi:int,zodiac:int,constellation:int,natal_chart:int,total:int,verdict:string,
     *  reasons_match:array<int,string>,reasons_mismatch:array<int,string>,confidence:float,
     *  module_details:array<string,array<string,mixed>>
     * }
     */
    public function score(array $a, array $b): array
    {
        $zodiac = $this->scoreZodiac((string) ($a['zodiac_animal'] ?? ''), (string) ($b['zodiac_animal'] ?? ''));
        $constellation = $this->scoreConstellation((string) ($a['public_zodiac_sign'] ?? ''), (string) ($b['public_zodiac_sign'] ?? ''));
        $bazi = $this->scoreBazi((string) ($a['private_bazi'] ?? ''), (string) ($b['private_bazi'] ?? ''), $a['private_natal_chart'] ?? null, $b['private_natal_chart'] ?? null);
        $chart = $this->scoreNatalChart($a['private_natal_chart'] ?? null, $b['private_natal_chart'] ?? null, (string) ($a['public_zodiac_sign'] ?? ''), (string) ($b['public_zodiac_sign'] ?? ''));

        $w = (array) config('match_rules.weights', []);
        $weightBazi = (float) ($w['bazi'] ?? 0.5);
        $weightZodiac = (float) ($w['zodiac'] ?? 0.3);
        $weightConstellation = (float) ($w['constellation'] ?? 0.1);
        $weightChart = (float) ($w['natal_chart'] ?? 0.1);
        $total = (int) round(
            ($bazi['score'] * $weightBazi)
            + ($zodiac['score'] * $weightZodiac)
            + ($constellation['score'] * $weightConstellation)
            + ($chart['score'] * $weightChart)
        );

        $threshold = (array) config('match_rules.verdict_thresholds', ['high' => 80, 'medium' => 60]);
        $verdict = $total >= (int) ($threshold['high'] ?? 80)
            ? 'high'
            : ($total >= (int) ($threshold['medium'] ?? 60) ? 'medium' : 'low');

        $modules = [
            [
                'key' => 'bazi',
                'name' => '八字',
                'score' => (int) $bazi['score'],
                'weight' => $weightBazi,
                'match' => (string) $bazi['match'],
                'mismatch' => (string) $bazi['mismatch'],
            ],
            [
                'key' => 'zodiac',
                'name' => '属相',
                'score' => (int) $zodiac['score'],
                'weight' => $weightZodiac,
                'match' => (string) $zodiac['match'],
                'mismatch' => (string) $zodiac['mismatch'],
            ],
            [
                'key' => 'constellation',
                'name' => '星座',
                'score' => (int) $constellation['score'],
                'weight' => $weightConstellation,
                'match' => (string) $constellation['match'],
                'mismatch' => (string) $constellation['mismatch'],
            ],
            [
                'key' => 'natal_chart',
                'name' => '星盘',
                'score' => (int) $chart['score'],
                'weight' => $weightChart,
                'match' => (string) $chart['match'],
                'mismatch' => (string) $chart['mismatch'],
            ],
        ];
        usort($modules, function (array $x, array $y): int {
            $wx = ((float) ($x['weight'] ?? 0.0)) * ((int) ($x['score'] ?? 0));
            $wy = ((float) ($y['weight'] ?? 0.0)) * ((int) ($y['score'] ?? 0));
            return $wy <=> $wx;
        });

        $reasonsMatch = [];
        $reasonsMismatch = [];
        foreach ($modules as $m) {
            $name = (string) ($m['name'] ?? '');
            $score = (int) ($m['score'] ?? 0);
            $matchText = trim((string) ($m['match'] ?? ''));
            $mismatchText = trim((string) ($m['mismatch'] ?? ''));
            if ($matchText !== '') {
                $reasonsMatch[] = sprintf('%s(%d分)：%s', $name, $score, $matchText);
            }
            if ($mismatchText !== '') {
                $reasonsMismatch[] = sprintf('%s(%d分)：%s', $name, $score, $mismatchText);
            }
        }
        $reasonsMatch = array_slice($reasonsMatch, 0, 3);
        $reasonsMismatch = array_slice($reasonsMismatch, 0, 2);

        $summary = sprintf(
            '综合匹配度%d分（八字%d%%、属相%d%%、星座%d%%、星盘%d%%）',
            max(0, min(100, $total)),
            $this->toPercent($weightBazi),
            $this->toPercent($weightZodiac),
            $this->toPercent($weightConstellation),
            $this->toPercent($weightChart)
        );

        return [
            'bazi' => $bazi['score'],
            'zodiac' => $zodiac['score'],
            'constellation' => $constellation['score'],
            'natal_chart' => $chart['score'],
            'total' => max(0, min(100, $total)),
            'verdict' => $verdict,
            'summary' => $summary,
            'reasons_match' => $reasonsMatch,
            'reasons_mismatch' => $reasonsMismatch,
            'confidence' => round(($bazi['confidence'] + $chart['confidence'] + 1.0 + 1.0) / 4, 2),
            'module_details' => [
                'bazi' => $bazi,
                'zodiac' => $zodiac,
                'constellation' => $constellation,
                'natal_chart' => $chart,
            ],
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreBazi(string $baziA, string $baziB, mixed $chartA, mixed $chartB): array
    {
        $tpl = (array) (((array) config('match_rules.bazi.templates', []))['full'] ?? []);
        $tplSimilarity = (array) (((array) config('match_rules.bazi.templates', []))['similarity'] ?? []);
        $tplDegraded = (array) (((array) config('match_rules.bazi.templates', []))['degraded'] ?? []);
        $wuA = $this->extractWuXing($chartA);
        $wuB = $this->extractWuXing($chartB);

        if (!empty($wuA) && !empty($wuB)) {
            $keys = ['木', '火', '土', '金', '水'];
            $sumA = max(1, array_sum(array_map(fn ($k) => (int) ($wuA[$k] ?? 0), $keys)));
            $sumB = max(1, array_sum(array_map(fn ($k) => (int) ($wuB[$k] ?? 0), $keys)));
            $dist = 0.0;
            foreach ($keys as $k) {
                $va = ((int) ($wuA[$k] ?? 0)) / $sumA;
                $vb = ((int) ($wuB[$k] ?? 0)) / $sumB;
                $dist += abs($va - $vb);
            }
            $target = (float) config('match_rules.bazi.fallback.with_wuxing_target_distance', 0.6);
            $part1 = max(0.0, 40 * (1 - abs($dist - $target) / $target));
            $part2 = 28.0; // simplified day-master relation placeholder for V1.
            $part3 = 20.0 - min(20.0, $dist * 10.0);
            $part4 = 10.0;
            $score = (int) round($part1 + $part2 + $part3 + $part4);

            return [
                'score' => max(0, min(100, $score)),
                'match' => (string) ($tpl['match'] ?? '八字五行互补度较好，节奏更容易协调'),
                'mismatch' => $score < 60 ? (string) ($tpl['mismatch'] ?? '八字五行分布偏差较大，可能需要更长磨合') : '',
                'confidence' => 1.0,
                'reason_short' => (string) ($tpl['short'] ?? '五行结构偏互补，长期磨合潜力较好。'),
                'reason_detail' => (string) ($tpl['detail'] ?? '从五行分布看，你们更偏向“互补调节”而非同侧堆叠，长期生活节律更容易形成稳定配合。'),
                'risk_detail' => $score < 60 ? (string) ($tpl['risk'] ?? '五行分布差异偏大，婚后在作息、决策与压力处理上可能出现节律不一致。') : '',
                'evidence_tags' => ['wu_xing_complement', 'long_term_harmony_oriented'],
                'evidence' => [
                    'wu_xing_a' => $wuA,
                    'wu_xing_b' => $wuB,
                    'wu_xing_distance' => round($dist, 4),
                    'target_distance' => $target,
                ],
                'degraded' => false,
                'degrade_reason' => '',
            ];
        }

        if ($baziA !== '' && $baziB !== '') {
            similar_text($baziA, $baziB, $percent);
            $score = (int) round(40 + ($percent * 0.45));
            return [
                'score' => max(0, min(100, $score)),
                'match' => (string) ($tplSimilarity['match'] ?? '八字信息完整，基础结构相容度中等偏上'),
                'mismatch' => $score < 60 ? (string) ($tplSimilarity['mismatch'] ?? '八字组合冲突项偏多，建议谨慎观察') : '',
                'confidence' => 0.75,
                'reason_short' => (string) ($tplSimilarity['short'] ?? '八字结构相容度中等偏上。'),
                'reason_detail' => (string) ($tplSimilarity['detail'] ?? '当前按八字文本结构相似度估算，倾向于“可磨合但需观察现实互动”的组合。'),
                'risk_detail' => $score < 60 ? (string) ($tplSimilarity['risk'] ?? '八字结构冲突项偏多，长期磨合成本可能偏高。') : '',
                'evidence_tags' => ['bazi_similarity_estimation', 'confidence_medium'],
                'evidence' => [
                    'bazi_a' => $baziA,
                    'bazi_b' => $baziB,
                    'similarity_percent' => round($percent, 2),
                ],
                'degraded' => true,
                'degrade_reason' => 'missing_wu_xing',
            ];
        }

        return [
            'score' => 55,
            'match' => (string) ($tplDegraded['match'] ?? '八字信息不完整，已使用保守估计'),
            'mismatch' => (string) ($tplDegraded['mismatch'] ?? '缺少完整八字或五行明细，结论置信度较低'),
            'confidence' => 0.4,
            'reason_short' => (string) ($tplDegraded['short'] ?? '八字数据不完整，当前仅作保守参考。'),
            'reason_detail' => (string) ($tplDegraded['detail'] ?? '缺少完整八字或五行明细，系统只能按简化规则估算，不建议把该项作为强结论。'),
            'risk_detail' => (string) ($tplDegraded['risk'] ?? '建议补全出生时刻与地点，提高长期结果判断的稳定性。'),
            'evidence_tags' => ['bazi_degraded_estimation', 'missing_bazi'],
            'evidence' => [],
            'degraded' => true,
            'degrade_reason' => 'missing_bazi',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreZodiac(string $a, string $b): array
    {
        $scores = (array) config('match_rules.zodiac.scores', []);
        $tplMatch = (array) config('match_rules.zodiac.templates.match', []);
        $tplDetail = (array) config('match_rules.zodiac.templates.detail', []);
        $tplRisk = (string) config('match_rules.zodiac.templates.risk', '该关系类型并非“不能在一起”，而是提示磨合与沟通成本相对更高。');
        if ($a === '' || $b === '') {
            return [
                'score' => 55,
                'match' => '属相信息缺失，使用中性评分',
                'mismatch' => '',
                'confidence' => 0.5,
                'reason_short' => '属相信息缺失，暂按中性倾向处理。',
                'reason_detail' => '当前缺少属相信息，无法判断六合/三合/冲刑害等关系，只能给出中性估计。',
                'risk_detail' => '',
                'evidence_tags' => ['missing_zodiac'],
                'evidence' => ['animal_a' => $a, 'animal_b' => $b],
                'degraded' => true,
                'degrade_reason' => 'missing_zodiac',
            ];
        }

        $relation = $this->zodiacRelation($a, $b);
        $score = (int) ($scores[$relation] ?? ($scores['normal'] ?? 55));
        $match = (string) ($tplMatch[$relation] ?? $tplMatch['normal'] ?? '属相关系一般，仍可通过沟通建立默契');
        $detail = (string) ($tplDetail[$relation] ?? $tplDetail['normal'] ?? "当前组合（{$a}-{$b}）不属于传统六合/三合，也不在冲刑害高风险组，建议以现实互动质量为主判断。");
        $mismatch = in_array($relation, ['chong', 'xing', 'hai'], true)
            ? (string) ($tplMatch[$relation] ?? '属相关系存在冲/刑/害，冲突概率相对更高')
            : '';
        $tags = match ($relation) {
            'liuhe' => ['zodiac_liuhe'],
            'sanhe' => ['zodiac_sanhe'],
            'same' => ['zodiac_same'],
            'chong' => ['zodiac_chong'],
            'xing' => ['zodiac_xing'],
            'hai' => ['zodiac_hai'],
            default => ['zodiac_normal'],
        };

        return [
            'score' => $score,
            'match' => $match,
            'mismatch' => $mismatch,
            'confidence' => 1.0,
            'reason_short' => $match,
            'reason_detail' => $detail,
            'risk_detail' => in_array($relation, ['chong', 'xing', 'hai'], true)
                ? $tplRisk
                : '',
            'evidence_tags' => $tags,
            'evidence' => ['animal_a' => $a, 'animal_b' => $b, 'relation_type' => $relation],
            'degraded' => false,
            'degrade_reason' => '',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreConstellation(string $a, string $b): array
    {
        $elements = (array) config('match_rules.constellation.elements', []);
        $tpl = (array) config('match_rules.constellation.templates', []);
        $tplDegraded = (array) ($tpl['degraded'] ?? []);
        if ($a === '' || $b === '' || !isset($elements[$a]) || !isset($elements[$b])) {
            return [
                'score' => 60,
                'match' => (string) ($tplDegraded['match'] ?? '星座信息不完整，采用基础评分'),
                'mismatch' => '',
                'confidence' => 0.6,
                'reason_short' => (string) ($tplDegraded['short'] ?? '星座信息不完整，当前仅作基础参考。'),
                'reason_detail' => (string) ($tplDegraded['detail'] ?? '因星座要素缺失，系统无法给出完整过程层判断，仅提供中性估计。'),
                'risk_detail' => '',
                'evidence_tags' => ['missing_constellation'],
                'evidence' => ['sign_a' => $a, 'sign_b' => $b],
                'degraded' => true,
                'degrade_reason' => 'missing_constellation',
            ];
        }
        $ea = $elements[$a];
        $eb = $elements[$b];
        $same = $ea === $eb;
        $complement = in_array([$ea, $eb], [
            ['fire', 'air'], ['air', 'fire'], ['earth', 'water'], ['water', 'earth'],
        ], true);

        $score = $same
            ? (int) config('match_rules.constellation.score_same_element', 85)
            : ($complement
                ? (int) config('match_rules.constellation.score_complement', 75)
                : (int) config('match_rules.constellation.score_normal', 60));
        if ($a === $b) {
            $score += (int) config('match_rules.constellation.same_sign_bonus', 5);
        }

        $mode = $same ? 'same' : ($complement ? 'complement' : 'tension');
        $tplMode = (array) ($tpl[$mode] ?? []);
        $tplRisk = (array) ($tpl['tension'] ?? []);
        return [
            'score' => max(0, min(100, $score)),
            'match' => (string) ($tplMode['match'] ?? ($same ? '同元素星座，沟通风格更易同频' : ($complement ? '星座元素互补，互动张力较好' : '星座元素差异较大，需要主动沟通'))),
            'mismatch' => $score < 65 ? '星座特质差异较明显，磨合成本可能偏高' : '',
            'confidence' => 1.0,
            'reason_short' => (string) ($tplMode['short'] ?? ($same ? '互动风格偏同频，推进更顺滑。' : ($complement ? '元素互补，互动张力与推进节奏较好。' : '互动节奏差异较大，需主动对齐。'))),
            'reason_detail' => (string) ($tplMode['detail'] ?? ($same
                ? '同元素组合通常在表达方式和节奏上更容易同步，过程层阻力相对更低。'
                : ($complement
                    ? '元素互补组合通常体现为一方推进、另一方承接更自然，初期互动更容易形成节奏。'
                    : '元素差异较大时，常见情况是表达逻辑与情绪节奏不同步，推进关系需要额外沟通。'))),
            'risk_detail' => $score < 65 ? (string) ($tplRisk['risk'] ?? '该项主要反映相处过程是否顺滑，不代表长期结果层结论。') : '',
            'evidence_tags' => $same ? ['same_element', 'process_layer_signal'] : ($complement ? ['element_complement', 'process_layer_signal'] : ['element_tension', 'process_layer_signal']),
            'evidence' => [
                'sign_a' => $a,
                'sign_b' => $b,
                'element_a' => $ea,
                'element_b' => $eb,
                'same_element' => $same,
                'complementary' => $complement,
            ],
            'degraded' => false,
            'degrade_reason' => '',
        ];
    }

    /**
     * @return array{
     *   score:int,match:string,mismatch:string,confidence:float,
     *   reason_short:string,reason_detail:string,risk_detail:string,
     *   evidence_tags:array<int,string>,evidence:array<string,mixed>,
     *   degraded:bool,degrade_reason:string
     * }
     */
    private function scoreNatalChart(mixed $chartA, mixed $chartB, string $sunA, string $sunB): array
    {
        $moonA = is_array($chartA) ? (string) ($chartA['moon_sign'] ?? '') : '';
        $moonB = is_array($chartB) ? (string) ($chartB['moon_sign'] ?? '') : '';
        $ascA = is_array($chartA) ? (string) ($chartA['asc_sign'] ?? '') : '';
        $ascB = is_array($chartB) ? (string) ($chartB['asc_sign'] ?? '') : '';

        $sunPart = $this->scoreConstellation($sunA, $sunB)['score'] * 0.30;
        $moonPart = ($moonA !== '' && $moonB !== '') ? ($this->scoreConstellation($moonA, $moonB)['score'] * 0.40) : 0;
        $ascPart = ($ascA !== '' && $ascB !== '') ? ($this->scoreConstellation($ascA, $ascB)['score'] * 0.20) : 0;
        $aspectPart = ($moonA !== '' && $moonB !== '' && $ascA !== '' && $ascB !== '') ? 8 : 4;

        $raw = (int) round($sunPart + $moonPart + $ascPart + $aspectPart);
        $max = 30 + (($moonA !== '' && $moonB !== '') ? 40 : 0) + (($ascA !== '' && $ascB !== '') ? 20 : 0) + 10;
        $score = $max > 0 ? (int) round($raw / $max * 100) : 60;
        $conf = $max >= 100 ? 1.0 : ($max >= 70 ? 0.7 : 0.4);

        return [
            'score' => max(0, min(100, $score)),
            'match' => $score >= 70 ? '星盘关键项相位较和谐，情绪与节奏更易同步' : '星盘结构一般，可通过互动逐步建立默契',
            'mismatch' => $score < 60 ? '星盘相位张力偏大，容易出现沟通温差' : '',
            'confidence' => $conf,
            'reason_short' => $score >= 70 ? '情绪节奏与互动推进更易同步。' : '星盘结构中性，需靠互动建立默契。',
            'reason_detail' => $score >= 70
                ? '月亮与上升等关键项更协调，通常意味着情绪回应与关系推进节奏更容易对上。'
                : '星盘关键项协同一般，更多需要依赖现实互动和沟通机制来建立稳定体验。',
            'risk_detail' => $score < 60 ? '该项反映过程层温差风险，建议在互动中增加反馈确认与节奏对齐。' : '',
            'evidence_tags' => $conf < 0.8
                ? ['natal_chart_partial_data']
                : ($score >= 70 ? ['moon_sync_high', 'asc_style_match'] : ['moon_sync_low', 'asc_style_gap']),
            'evidence' => [
                'sun_sign_a' => $sunA,
                'sun_sign_b' => $sunB,
                'moon_sign_a' => $moonA,
                'moon_sign_b' => $moonB,
                'asc_sign_a' => $ascA,
                'asc_sign_b' => $ascB,
                'data_completeness' => $max,
            ],
            'degraded' => $conf < 0.8,
            'degrade_reason' => $conf < 0.8 ? 'partial_natal_chart' : '',
        ];
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

    private function zodiacRelation(string $a, string $b): string
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

    private function toPercent(float $weight): int
    {
        return (int) round(max(0.0, min(1.0, $weight)) * 100);
    }
}
