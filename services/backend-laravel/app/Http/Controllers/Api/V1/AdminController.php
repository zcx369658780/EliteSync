<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;

class AdminController extends Controller
{
    private function weekTag(): string
    {
        return now()->utc()->format('Y-\\WW');
    }

    public function users(): JsonResponse
    {
        $items = User::query()
            ->orderBy('id')
            ->get(['id', 'phone', 'name', 'disabled', 'verify_status']);

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function verifyQueue(): JsonResponse
    {
        $items = User::query()
            ->where('verify_status', '!=', 'approved')
            ->orderBy('id')
            ->get(['id', 'phone', 'name', 'verify_status']);

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function updateVerify(Request $request, int $uid): JsonResponse
    {
        $data = $request->validate([
            'status' => ['required', 'string', 'in:pending,approved,rejected'],
        ]);

        $user = User::find($uid);
        if (!$user) {
            return response()->json(['message' => 'user not found'], 404);
        }

        $user->verify_status = $data['status'];
        $user->save();

        return response()->json(['ok' => true]);
    }

    public function disable(int $uid): JsonResponse
    {
        $user = User::find($uid);
        if (!$user) {
            return response()->json(['message' => 'user not found'], 404);
        }

        $user->disabled = true;
        $user->save();

        return response()->json(['ok' => true]);
    }

    public function devRunMatching(): JsonResponse
    {
        $weekTag = $this->weekTag();
        $totalQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();

        if ($totalQuestions === 0) {
            return response()->json([
                'ok' => true,
                'week_tag' => $weekTag,
                'pairs' => 0,
                'eligible_users' => 0,
                'message' => 'no enabled questions',
                'match_ids' => [],
            ]);
        }

        $eligibleUserIds = QuestionnaireAnswer::query()
            ->select('user_id')
            ->groupBy('user_id')
            ->havingRaw('COUNT(DISTINCT questionnaire_question_id) >= ?', [$totalQuestions]);

        $users = User::query()
            ->where('disabled', false)
            ->whereIn('id', $eligibleUserIds)
            ->orderBy('id')
            ->get(['id']);

        $pairs = 0;
        $createdMatchIds = [];

        /** @var Collection<int, User> $chunks */
        $chunks = $users->chunk(2);
        foreach ($chunks as $chunk) {
            if ($chunk->count() < 2) {
                continue;
            }

            $a = (int) $chunk[0]->id;
            $b = (int) $chunk[1]->id;

            $exists = DatingMatch::query()
                ->where('week_tag', $weekTag)
                ->where(function ($q) use ($a, $b) {
                    $q->where(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $a)->where('user_b', $b);
                    })->orWhere(function ($pair) use ($a, $b) {
                        $pair->where('user_a', $b)->where('user_b', $a);
                    });
                })
                ->first();

            if ($exists) {
                $createdMatchIds[] = $exists->id;
                continue;
            }

            $match = DatingMatch::create([
                'week_tag' => $weekTag,
                'user_a' => $a,
                'user_b' => $b,
                'highlights' => '开发态匹配：用于联调',
                'drop_released' => false,
            ]);
            $pairs++;
            $createdMatchIds[] = $match->id;
        }

        return response()->json([
            'ok' => true,
            'week_tag' => $weekTag,
            'pairs' => $pairs,
            'eligible_users' => $users->count(),
            'match_ids' => $createdMatchIds,
        ]);
    }

    public function devReleaseDrop(): JsonResponse
    {
        $weekTag = $this->weekTag();
        $updated = DatingMatch::query()
            ->where('week_tag', $weekTag)
            ->update(['drop_released' => true]);

        return response()->json([
            'ok' => true,
            'week_tag' => $weekTag,
            'released' => $updated,
        ]);
    }
}
