<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\User;
use App\Services\EventLogger;
use App\Services\MatchingDebugModeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Schema;

class MatchController extends Controller
{
    /**
     * @return list<string>
     */
    private function userIdentityColumns(): array
    {
        $columns = ['id', 'name', 'phone'];
        if (Schema::hasColumn('users', 'nickname')) {
            $columns[] = 'nickname';
        }
        return $columns;
    }

    private function requiredAnswerCount(): int
    {
        return max(1, (int) config('questionnaire.required_answer_count', 10));
    }

    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    /**
     * @param array<string,mixed>|null $raw
     * @return array<string,mixed>
     */
    private function normalizeMatchReasons(?array $raw, DatingMatch $match): array
    {
        $contractVersion = (string) config('matching.contract.version', 'v1');
        $normalized = $raw ?? [];
        $normalized['contract_version'] = (string) ($normalized['contract_version'] ?? $contractVersion);
        $normalized['generated_at'] = (string) ($normalized['generated_at'] ?? optional($match->updated_at)->toIso8601String() ?? now()->toIso8601String());
        $normalized['summary'] = (string) ($normalized['summary'] ?? '');
        $normalized['match'] = array_values((array) ($normalized['match'] ?? []));
        $normalized['mismatch'] = array_values((array) ($normalized['mismatch'] ?? []));
        $normalized['confidence'] = (float) ($normalized['confidence'] ?? 0.5);
        $normalized['display_score'] = (int) ($normalized['display_score'] ?? ($match->score_final ?? 0));
        $normalized['rank_score'] = (int) ($normalized['rank_score'] ?? ($match->score_fair ?? 0));
        $normalized['modules'] = array_values((array) ($normalized['modules'] ?? []));

        foreach ($normalized['modules'] as &$module) {
            if (!is_array($module)) {
                $module = [];
            }
            $key = (string) ($module['key'] ?? '');
            $algoVersion = (string) config("matching.algo_versions.{$key}", 'p1');
            $module['algo_version'] = (string) ($module['algo_version'] ?? $algoVersion);
            $tags = array_values(array_unique(array_filter(array_map(
                fn ($v) => strtolower(trim((string) $v)),
                (array) ($module['evidence_tags'] ?? [])
            ))));
            $module['evidence_tags'] = $tags;
            $module['evidence_tag_labels'] = array_map(function (string $tag): string {
                $meta = $this->evidenceTagMeta($tag);
                return (string) ($meta['label'] ?? $tag);
            }, $tags);
        }
        unset($module);
        $normalized['module_explanations'] = array_values(array_map(function ($module): array {
            $row = is_array($module) ? $module : [];
            $label = trim((string) ($row['label'] ?? $row['key'] ?? '匹配项'));
            $score = (int) ($row['score'] ?? 0);
            $confidence = (float) ($row['confidence'] ?? 0.5);
            $degraded = (bool) ($row['degraded'] ?? false);
            $degradeReason = trim((string) ($row['degrade_reason'] ?? ''));
            $reason = trim((string) ($row['reason_detail'] ?? $row['reason_short'] ?? '暂无解释'));
            $risk = trim((string) ($row['risk_short'] ?? $row['risk_detail'] ?? ''));
            $tags = array_values((array) ($row['evidence_tag_labels'] ?? $row['evidence_tags'] ?? []));
            $split = $this->splitEvidenceLabels($tags, $label);
            $tagExplains = $this->buildEvidenceLabelDescriptions($row);
            $tagRefs = $this->buildEvidenceLabelReferences($row);
            $riskLevel = 'low';
            if ($risk !== '' || $score < 70) {
                if ($score < 60 || str_contains($risk, '冲') || str_contains($risk, '刑') || str_contains($risk, '害')) {
                    $riskLevel = 'high';
                } else {
                    $riskLevel = 'medium';
                }
            }
            $riskWeight = $riskLevel === 'high' ? 300 : ($riskLevel === 'medium' ? 200 : 100);
            $degradedWeight = $degraded ? 30 : 0;
            $lowConfidenceWeight = (int) round((1.0 - max(0.0, min(1.0, $confidence))) * 80);
            $lowScoreWeight = (int) round((100 - max(0, min(100, $score))) * 0.6);
            $priority = $riskWeight + $degradedWeight + $lowConfidenceWeight + $lowScoreWeight;
            $priorityLevel = $priority >= 300 ? 'high' : ($priority >= 220 ? 'medium' : 'normal');
            $priorityReason = $this->buildPriorityReason($riskLevel, $degraded, $confidence, $score);
            $evidenceStrength = $this->buildEvidenceStrength(
                $split['core'],
                $split['aux'],
                $confidence,
                $degraded
            );
            return [
                'label' => $label === '' ? '匹配项' : $label,
                'score' => $score,
                'confidence' => round(max(0.0, min(1.0, $confidence)), 2),
                'degraded' => $degraded,
                'degrade_reason' => $degradeReason,
                'reason' => $reason === '' ? '暂无解释' : $reason,
                'risk' => $risk,
                'risk_level' => $riskLevel,
                'priority' => $priority,
                'priority_level' => $priorityLevel,
                'priority_reason' => $priorityReason,
                'evidence_strength' => $evidenceStrength['level'],
                'evidence_strength_reason' => $evidenceStrength['reason'],
                'tags' => array_values(array_filter(array_map(fn ($v) => trim((string) $v), $tags), fn ($v) => $v !== '')),
                'core_tags' => $split['core'],
                'aux_tags' => $split['aux'],
                'core_tag_explains' => $this->pickTagExplains($split['core'], $tagExplains),
                'aux_tag_explains' => $this->pickTagExplains($split['aux'], $tagExplains),
                'core_tag_refs' => $this->pickTagExplains($split['core'], $tagRefs),
                'aux_tag_refs' => $this->pickTagExplains($split['aux'], $tagRefs),
            ];
        }, $normalized['modules']));
        usort($normalized['module_explanations'], function (array $a, array $b): int {
            $pa = (int) ($a['priority'] ?? 0);
            $pb = (int) ($b['priority'] ?? 0);
            if ($pa !== $pb) {
                return $pb <=> $pa;
            }
            $sa = (int) ($a['score'] ?? 0);
            $sb = (int) ($b['score'] ?? 0);
            return $sa <=> $sb;
        });
        foreach ($normalized['module_explanations'] as $idx => &$row) {
            if (!is_array($row)) {
                $row = [];
            }
            $row['priority_rank'] = $idx + 1;
        }
        unset($row);
        $normalized['evidence_strength_summary'] = $this->buildEvidenceStrengthSummary(
            $normalized['module_explanations']
        );
        $normalized['reason_glossary'] = $this->buildReasonGlossary($normalized);

        return $normalized;
    }

    /**
     * @param array<string,mixed> $reasons
     * @return array<string,string>
     */
    private function buildReasonGlossary(array $reasons): array
    {
        $seed = [
            '八字' => '基于出生信息推算的结构，用于观察长期生活节奏与稳定性倾向。',
            '五行' => '木火土金水的分布结构，主要看互补与均衡，不作为绝对结论。',
            '属相六合' => '传统上协同度较高的属相关系，通常更容易形成配合感。',
            '属相三合' => '传统分组中的协同关系，通常表示节奏更容易对齐。',
            '相冲/相刑/相害' => '表示磨合成本可能偏高，建议提前明确沟通边界。',
            '星座元素' => '火土风水四元素倾向，主要用于过程层互动顺滑度判断。',
            '星盘' => '结合太阳/月亮/上升等要素的过程层分析，偏向“如何相处”。',
            '合盘' => '将双方盘面组合后的过程层分析，关注互动路径与磨合成本。',
            '证据标签' => '用于说明每个结论来自哪些信号，便于复盘与解释。',
        ];

        $moduleTerms = [];
        foreach ((array) ($reasons['modules'] ?? []) as $module) {
            if (!is_array($module)) {
                continue;
            }
            $label = trim((string) ($module['label'] ?? ''));
            if ($label !== '') {
                $moduleTerms[] = $label;
            }
            foreach ((array) ($module['evidence_tags'] ?? []) as $tag) {
                $tv = strtolower(trim((string) $tag));
                if ($tv === '') {
                    continue;
                }
                $moduleTerms = array_merge($moduleTerms, $this->mapEvidenceTagToTerms($tv));
            }
            $moduleTerms = array_merge(
                $moduleTerms,
                $this->extractTermsFromText((string) ($module['reason_short'] ?? '')),
                $this->extractTermsFromText((string) ($module['reason_detail'] ?? '')),
                $this->extractTermsFromText((string) ($module['risk_short'] ?? '')),
                $this->extractTermsFromText((string) ($module['risk_detail'] ?? ''))
            );
        }
        foreach ((array) ($reasons['match'] ?? []) as $line) {
            $moduleTerms = array_merge($moduleTerms, $this->extractTermsFromText((string) $line));
        }
        foreach ((array) ($reasons['mismatch'] ?? []) as $line) {
            $moduleTerms = array_merge($moduleTerms, $this->extractTermsFromText((string) $line));
        }

        $out = [];
        foreach (array_unique($moduleTerms) as $term) {
            if (isset($seed[$term])) {
                $out[$term] = $seed[$term];
            }
        }
        // Always keep these two generic glossary entries for UI fallback.
        $out += [
            '证据标签' => $seed['证据标签'],
            '合盘' => $seed['合盘'],
        ];

        return $out;
    }

    /**
     * @return list<string>
     */
    private function mapEvidenceTagToTerms(string $tag): array
    {
        $meta = $this->evidenceTagMeta($tag);
        $terms = (array) ($meta['terms'] ?? []);
        if (!empty($terms)) {
            return array_values(array_unique(array_filter(array_map('strval', $terms))));
        }

        $terms = [];
        if (str_contains($tag, 'zodiac')) {
            $terms[] = '属相六合';
            $terms[] = '属相三合';
            $terms[] = '相冲/相刑/相害';
        }
        if (str_contains($tag, 'wu_xing') || str_contains($tag, 'bazi')) {
            $terms[] = '八字';
            $terms[] = '五行';
        }
        if (str_contains($tag, 'natal') || str_contains($tag, 'moon') || str_contains($tag, 'asc')) {
            $terms[] = '星盘';
        }
        if (str_contains($tag, 'pair_chart') || str_contains($tag, 'sun_moon')) {
            $terms[] = '合盘';
        }
        if (str_contains($tag, 'element') || str_contains($tag, 'constellation')) {
            $terms[] = '星座元素';
        }
        return $terms;
    }

    /**
     * @return array<string,mixed>
     */
    private function evidenceTagMeta(string $tag): array
    {
        $dict = (array) config('match_evidence_tags', []);
        return (array) ($dict[strtolower(trim($tag))] ?? []);
    }

    /**
     * @return list<string>
     */
    private function extractTermsFromText(string $text): array
    {
        $v = trim($text);
        if ($v === '') {
            return [];
        }
        $matched = [];
        $keywords = [
            '八字' => '八字',
            '五行' => '五行',
            '六合' => '属相六合',
            '三合' => '属相三合',
            '相冲' => '相冲/相刑/相害',
            '相刑' => '相冲/相刑/相害',
            '相害' => '相冲/相刑/相害',
            '星盘' => '星盘',
            '上升' => '星盘',
            '月亮' => '星盘',
            '太阳' => '星盘',
            '星座' => '星座元素',
            '元素' => '星座元素',
            '合盘' => '合盘',
        ];
        foreach ($keywords as $k => $term) {
            if (str_contains($v, $k)) {
                $matched[] = $term;
            }
        }
        return array_values(array_unique($matched));
    }

    /**
     * @param list<string> $labels
     * @return array{core:list<string>,aux:list<string>}
     */
    private function splitEvidenceLabels(array $labels, string $moduleLabel): array
    {
        $clean = array_values(array_filter(array_map(
            fn ($v) => trim((string) $v),
            $labels
        ), fn ($v) => $v !== ''));
        if (empty($clean)) {
            return ['core' => [], 'aux' => []];
        }
        $core = [];
        $aux = [];
        foreach ($clean as $label) {
            if ($this->isCoreEvidenceLabel($label, $moduleLabel)) {
                $core[] = $label;
            } else {
                $aux[] = $label;
            }
        }
        if (empty($core) && !empty($aux)) {
            $core[] = (string) array_shift($aux);
        }
        return [
            'core' => array_values(array_unique($core)),
            'aux' => array_values(array_unique($aux)),
        ];
    }

    private function isCoreEvidenceLabel(string $label, string $moduleLabel): bool
    {
        $v = mb_strtolower(trim($label));
        $module = mb_strtolower(trim($moduleLabel));
        $coreKeywords = [
            '六合', '三合', '相冲', '相刑', '相害',
            '五行', '八字', '地支',
            '日月', '上升', '合盘', '星盘',
            'mbti', '人格',
        ];
        foreach ($coreKeywords as $k) {
            if (str_contains($v, mb_strtolower($k))) {
                return true;
            }
        }
        if ($module !== '' && str_contains($v, $module)) {
            return true;
        }
        return false;
    }

    private function buildPriorityReason(string $riskLevel, bool $degraded, float $confidence, int $score): string
    {
        $parts = [];
        if ($riskLevel === 'high') {
            $parts[] = '风险等级高';
        } elseif ($riskLevel === 'medium') {
            $parts[] = '风险等级中';
        }
        if ($degraded) {
            $parts[] = '存在降级估算';
        }
        if ($confidence < 0.6) {
            $parts[] = '置信度偏低';
        }
        if ($score < 60) {
            $parts[] = '分项得分偏低';
        }
        if (empty($parts)) {
            return '当前为常规关注项';
        }
        return implode('、', $parts);
    }

    /**
     * @param list<string> $coreTags
     * @param list<string> $auxTags
     * @return array{level:string,reason:string}
     */
    private function buildEvidenceStrength(array $coreTags, array $auxTags, float $confidence, bool $degraded): array
    {
        $score = 0;
        $reasons = [];
        $coreCount = count($coreTags);
        $auxCount = count($auxTags);

        if ($coreCount >= 2) {
            $score += 2;
            $reasons[] = '核心证据充足';
        } elseif ($coreCount === 1) {
            $score += 1;
            $reasons[] = '具备核心证据';
        } else {
            $score -= 1;
            $reasons[] = '核心证据不足';
        }

        if ($auxCount >= 2) {
            $score += 1;
            $reasons[] = '辅助证据较多';
        } elseif ($auxCount === 0) {
            $reasons[] = '辅助证据较少';
        }

        if ($confidence >= 0.8) {
            $score += 1;
            $reasons[] = '置信度高';
        } elseif ($confidence < 0.6) {
            $score -= 1;
            $reasons[] = '置信度偏低';
        }

        if ($degraded) {
            $score -= 1;
            $reasons[] = '存在降级估算';
        }

        $level = 'low';
        if ($score >= 3) {
            $level = 'high';
        } elseif ($score >= 1) {
            $level = 'medium';
        }

        return [
            'level' => $level,
            'reason' => implode('、', array_values(array_unique($reasons))),
        ];
    }

    /**
     * @param array<string,mixed> $module
     * @return array<string,string>
     */
    private function buildEvidenceLabelDescriptions(array $module): array
    {
        $out = [];
        $tags = array_values((array) ($module['evidence_tags'] ?? []));
        $labels = array_values((array) ($module['evidence_tag_labels'] ?? []));
        foreach ($tags as $i => $rawTag) {
            $tag = strtolower(trim((string) $rawTag));
            $label = trim((string) ($labels[$i] ?? $tag));
            if ($label === '') {
                continue;
            }
            $meta = $this->evidenceTagMeta($tag);
            $desc = trim((string) ($meta['description'] ?? ''));
            if ($desc !== '') {
                $out[$label] = $desc;
            }
        }
        return $out;
    }

    /**
     * @param array<string,mixed> $module
     * @return array<string,string>
     */
    private function buildEvidenceLabelReferences(array $module): array
    {
        $out = [];
        $tags = array_values((array) ($module['evidence_tags'] ?? []));
        $labels = array_values((array) ($module['evidence_tag_labels'] ?? []));
        foreach ($tags as $i => $rawTag) {
            $tag = strtolower(trim((string) $rawTag));
            $label = trim((string) ($labels[$i] ?? $tag));
            if ($label === '') {
                continue;
            }
            $meta = $this->evidenceTagMeta($tag);
            $ref = trim((string) ($meta['reference'] ?? ''));
            if ($ref !== '') {
                $out[$label] = $ref;
            }
        }
        return $out;
    }

    /**
     * @param array<int,array<string,mixed>> $rows
     * @return array<string,mixed>
     */
    private function buildEvidenceStrengthSummary(array $rows): array
    {
        $high = 0;
        $medium = 0;
        $low = 0;
        $weakModules = [];
        foreach ($rows as $row) {
            $level = strtolower(trim((string) ($row['evidence_strength'] ?? 'low')));
            if ($level === 'high') {
                $high++;
            } elseif ($level === 'medium') {
                $medium++;
            } else {
                $low++;
                $label = trim((string) ($row['label'] ?? ''));
                if ($label !== '') {
                    $weakModules[] = [
                        'label' => $label,
                        'reason' => trim((string) ($row['evidence_strength_reason'] ?? '')),
                        'priority_rank' => (int) ($row['priority_rank'] ?? 0),
                    ];
                }
            }
        }
        $weakModules = array_slice($weakModules, 0, 3);
        return [
            'high' => $high,
            'medium' => $medium,
            'low' => $low,
            'total' => count($rows),
            'weak_modules' => array_values(array_map(
                fn (array $m): array => [
                    'label' => (string) ($m['label'] ?? ''),
                    'reason' => (string) ($m['reason'] ?? ''),
                    'priority_rank' => (int) ($m['priority_rank'] ?? 0),
                ],
                $weakModules
            )),
        ];
    }

    /**
     * @param list<string> $labels
     * @param array<string,string> $descMap
     * @return array<string,string>
     */
    private function pickTagExplains(array $labels, array $descMap): array
    {
        $out = [];
        foreach ($labels as $label) {
            $v = trim((string) $label);
            if ($v === '') {
                continue;
            }
            $desc = trim((string) ($descMap[$v] ?? ''));
            if ($desc !== '') {
                $out[$v] = $desc;
            }
        }
        return $out;
    }

    public function current(Request $request, EventLogger $events): JsonResponse
    {
        $user = $request->user();
        $includeSyntheticUsers = app(MatchingDebugModeService::class)->includeSyntheticUsers();
        $answeredCount = QuestionnaireAnswer::query()
            ->where('user_id', $user->id)
            ->distinct('questionnaire_question_id')
            ->count('questionnaire_question_id');
        $required = $this->requiredAnswerCount();

        if ($answeredCount < $required) {
            return response()->json(['message' => 'questionnaire incomplete'], 404);
        }

        $match = DatingMatch::query()
            ->where('week_tag', $this->weekTag())
            ->where(function ($q) use ($user) {
                $q->where('user_a', $user->id)
                    ->orWhere('user_b', $user->id);
            })
            ->first();

        if (!$match) {
            return response()->json(['message' => 'no match'], 404);
        }

        if (!$match->drop_released) {
            return response()->json(['message' => 'drop not available'], 404);
        }

        $partnerId = $match->user_a == $user->id ? $match->user_b : $match->user_a;
        $partnerUser = User::query()->find((int) $partnerId);
        $partnerNickname = '';
        if ($partnerUser) {
            $partnerNickname = (string) ($partnerUser->nickname ?? $partnerUser->name ?? $partnerUser->phone ?? '');
        }
        if (!$includeSyntheticUsers) {
            $partnerSynthetic = (bool) User::query()
                ->where('id', (int) $partnerId)
                ->value('is_synthetic');
            if ($partnerSynthetic) {
                return response()->json(['message' => 'no match'], 404);
            }
        }
        $events->log(
            eventName: 'match_exposed',
            actorUserId: (int) $user->id,
            targetUserId: (int) $partnerId,
            matchId: (int) $match->id,
            payload: ['week_tag' => $match->week_tag]
        );

        return response()->json([
            'match_id' => $match->id,
            'partner_id' => $partnerId,
            'partner_nickname' => $partnerNickname,
            'highlights' => $match->highlights ?? '',
            'explanation_tags' => $match->explanation_tags ?? [],
            'base_score' => $match->score_base,
            'final_score' => $match->score_final,
            'fairness_adjusted_score' => $match->score_fair,
            'core_scores' => [
                'personality' => $match->score_personality_total,
                'mbti' => $match->score_mbti_total,
                'astro' => $match->score_astro_total,
                'overall' => $match->score_overall,
            ],
            'astro_scores' => [
                'bazi' => $match->score_bazi,
                'zodiac' => $match->score_zodiac,
                'constellation' => $match->score_constellation,
                'natal_chart' => $match->score_natal_chart,
            ],
            'match_verdict' => $match->match_verdict,
            'match_reasons' => $this->normalizeMatchReasons($match->match_reasons, $match),
            'penalty_factors' => $match->penalty_factors ?? [],
            'display_score' => (int) data_get($match->match_reasons, 'display_score', $match->score_final ?? 0),
            'rank_score' => (int) data_get($match->match_reasons, 'rank_score', $match->score_fair ?? 0),
        ]);
    }

    public function confirm(Request $request, EventLogger $events): JsonResponse
    {
        $data = $request->validate([
            'match_id' => ['required', 'integer', 'exists:dating_matches,id'],
            'like' => ['required', 'boolean'],
        ]);

        $user = $request->user();
        $match = DatingMatch::findOrFail($data['match_id']);

        if ($user->id == $match->user_a) {
            $match->like_a = $data['like'];
        } elseif ($user->id == $match->user_b) {
            $match->like_b = $data['like'];
        } else {
            return response()->json(['message' => 'not in match'], 403);
        }

        $match->save();
        $match->refresh();
        $partnerId = (int) ($user->id == $match->user_a ? $match->user_b : $match->user_a);
        $events->log(
            eventName: 'match_confirm',
            actorUserId: (int) $user->id,
            targetUserId: $partnerId,
            matchId: (int) $match->id,
            payload: ['like' => (bool) $data['like']]
        );

        return response()->json([
            'mutual' => (bool) $match->like_a && (bool) $match->like_b,
        ]);
    }

    public function history(Request $request): JsonResponse
    {
        $user = $request->user();
        $includeSyntheticUsers = app(MatchingDebugModeService::class)->includeSyntheticUsers();

        $rows = DatingMatch::query()
            ->where(function ($q) use ($user) {
                $q->where('user_a', $user->id)
                    ->orWhere('user_b', $user->id);
            })
            ->orderByDesc('id')
            ->get();

        $partnerIds = $rows
            ->map(fn (DatingMatch $m) => (int) ($m->user_a == $user->id ? $m->user_b : $m->user_a))
            ->unique()
            ->values();
        $partnerInfoMap = User::query()
            ->whereIn('id', $partnerIds)
            ->get($this->userIdentityColumns())
            ->keyBy('id');
        $syntheticMap = User::query()
            ->whereIn('id', $partnerIds)
            ->pluck('is_synthetic', 'id');

        $items = $rows
            ->filter(function (DatingMatch $match) use ($user, $includeSyntheticUsers, $syntheticMap) {
                if ($includeSyntheticUsers) {
                    return true;
                }
                $partnerId = (int) ($match->user_a == $user->id ? $match->user_b : $match->user_a);
                return !(bool) ($syntheticMap[$partnerId] ?? false);
            })
            ->map(function (DatingMatch $match) use ($user, $partnerInfoMap) {
                $partnerId = (int) ($match->user_a == $user->id ? $match->user_b : $match->user_a);
                $partner = $partnerInfoMap->get($partnerId);
                $partnerNickname = '';
                if ($partner) {
                    $partnerNickname = (string) ($partner->nickname ?? $partner->name ?? $partner->phone ?? '');
                }
                return [
                    'match_id' => $match->id,
                    'week_tag' => $match->week_tag,
                    'partner_id' => $partnerId,
                    'partner_nickname' => $partnerNickname,
                    'highlights' => $match->highlights ?? '',
                    'explanation_tags' => $match->explanation_tags ?? [],
                    'base_score' => $match->score_base,
                    'final_score' => $match->score_final,
                    'fairness_adjusted_score' => $match->score_fair,
                    'core_scores' => [
                        'personality' => $match->score_personality_total,
                        'mbti' => $match->score_mbti_total,
                        'astro' => $match->score_astro_total,
                        'overall' => $match->score_overall,
                    ],
                    'astro_scores' => [
                        'bazi' => $match->score_bazi,
                        'zodiac' => $match->score_zodiac,
                        'constellation' => $match->score_constellation,
                        'natal_chart' => $match->score_natal_chart,
                    ],
                    'match_verdict' => $match->match_verdict,
                    'match_reasons' => $this->normalizeMatchReasons($match->match_reasons, $match),
                    'penalty_factors' => $match->penalty_factors ?? [],
                    'display_score' => (int) data_get($match->match_reasons, 'display_score', $match->score_final ?? 0),
                    'rank_score' => (int) data_get($match->match_reasons, 'rank_score', $match->score_fair ?? 0),
                    'drop_released' => $match->drop_released,
                    'like_self' => $match->user_a == $user->id ? $match->like_a : $match->like_b,
                    'like_partner' => $match->user_a == $user->id ? $match->like_b : $match->like_a,
                ];
            })
            ->values();

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function explanationByTarget(Request $request, int $targetUserId): JsonResponse
    {
        $user = $request->user();
        $includeSyntheticUsers = app(MatchingDebugModeService::class)->includeSyntheticUsers();

        if ($targetUserId <= 0 || $targetUserId === (int) $user->id) {
            return response()->json(['message' => 'invalid target user'], 422);
        }

        if (!$includeSyntheticUsers) {
            $targetSynthetic = (bool) User::query()
                ->where('id', $targetUserId)
                ->value('is_synthetic');
            if ($targetSynthetic) {
                return response()->json(['message' => 'no match'], 404);
            }
        }

        $match = DatingMatch::query()
            ->where(function ($q) use ($user, $targetUserId) {
                $q->where('user_a', $user->id)->where('user_b', $targetUserId);
            })
            ->orWhere(function ($q) use ($user, $targetUserId) {
                $q->where('user_a', $targetUserId)->where('user_b', $user->id);
            })
            ->orderByDesc('id')
            ->first();

        if (!$match) {
            return response()->json(['message' => 'no match'], 404);
        }

        $targetUser = User::query()->find($targetUserId, $this->userIdentityColumns());
        $targetNickname = '';
        if ($targetUser) {
            $targetNickname = (string) ($targetUser->nickname ?? $targetUser->name ?? $targetUser->phone ?? '');
        }

        return response()->json([
            'match_id' => (int) $match->id,
            'partner_id' => $targetUserId,
            'partner_nickname' => $targetNickname,
            'week_tag' => (string) $match->week_tag,
            'drop_released' => (bool) $match->drop_released,
            'base_score' => (int) ($match->score_base ?? 0),
            'final_score' => (int) ($match->score_final ?? 0),
            'fairness_adjusted_score' => (int) ($match->score_fair ?? 0),
            'display_score' => (int) data_get($match->match_reasons, 'display_score', $match->score_final ?? 0),
            'rank_score' => (int) data_get($match->match_reasons, 'rank_score', $match->score_fair ?? 0),
            'match_verdict' => (string) ($match->match_verdict ?? ''),
            'highlights' => (string) ($match->highlights ?? ''),
            'explanation_tags' => (array) ($match->explanation_tags ?? []),
            'match_reasons' => $this->normalizeMatchReasons($match->match_reasons, $match),
            'penalty_factors' => (array) ($match->penalty_factors ?? []),
        ]);
    }
}
