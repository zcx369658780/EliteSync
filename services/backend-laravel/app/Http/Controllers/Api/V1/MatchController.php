<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Services\EventLogger;
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

    public function current(Request $request, EventLogger $events): JsonResponse
    {
        $user = $request->user();
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
            'highlights' => $match->highlights ?? '',
            'explanation_tags' => $match->explanation_tags ?? [],
            'base_score' => $match->score_base,
            'final_score' => $match->score_final,
            'fairness_adjusted_score' => $match->score_fair,
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

        $items = DatingMatch::query()
            ->where(function ($q) use ($user) {
                $q->where('user_a', $user->id)
                    ->orWhere('user_b', $user->id);
            })
            ->orderByDesc('id')
            ->get()
            ->map(function (DatingMatch $match) use ($user) {
                return [
                    'match_id' => $match->id,
                    'week_tag' => $match->week_tag,
                    'partner_id' => $match->user_a == $user->id ? $match->user_b : $match->user_a,
                    'highlights' => $match->highlights ?? '',
                    'explanation_tags' => $match->explanation_tags ?? [],
                    'base_score' => $match->score_base,
                    'final_score' => $match->score_final,
                    'fairness_adjusted_score' => $match->score_fair,
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
