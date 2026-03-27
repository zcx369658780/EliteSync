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

class MatchController extends Controller
{
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

        return $normalized;
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
            ->get(['id', 'nickname', 'name', 'phone'])
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
