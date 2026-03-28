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
        $normalized['modules'] = array_values((array) ($normalized['modules'] ?? []));

        foreach ($normalized['modules'] as &$module) {
            if (!is_array($module)) {
                $module = [];
            }
            $key = (string) ($module['key'] ?? '');
            $algoVersion = (string) config("matching.algo_versions.{$key}", 'p1');
            $module['algo_version'] = (string) ($module['algo_version'] ?? $algoVersion);
        }
        unset($module);
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
}
