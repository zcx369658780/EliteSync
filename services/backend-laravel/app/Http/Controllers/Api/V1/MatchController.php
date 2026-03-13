<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MatchController extends Controller
{
    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function current(Request $request): JsonResponse
    {
        $user = $request->user();
        $totalQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();
        $answeredCount = QuestionnaireAnswer::query()
            ->where('user_id', $user->id)
            ->distinct('questionnaire_question_id')
            ->count('questionnaire_question_id');

        if ($totalQuestions === 0 || $answeredCount < $totalQuestions) {
            return response()->json(['message' => 'questionnaire incomplete'], 404);
        }

        $match = DatingMatch::query()
            ->where('week_tag', $this->weekTag())
            ->where(function ($q) use ($user) {
                $q->where('user_a', $user->id)
                    ->orWhere('user_b', $user->id);
            })
            ->first();

        if (!$match || !$match->drop_released) {
            return response()->json(['message' => 'drop not available'], 404);
        }

        $partnerId = $match->user_a == $user->id ? $match->user_b : $match->user_a;

        return response()->json([
            'match_id' => $match->id,
            'partner_id' => $partnerId,
            'highlights' => $match->highlights ?? '',
        ]);
    }

    public function confirm(Request $request): JsonResponse
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
