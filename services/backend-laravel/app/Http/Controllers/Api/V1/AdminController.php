<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\DatingMatch;
use App\Models\ModerationReport;
use App\Models\QuestionnaireAnswer;
use App\Models\QuestionnaireQuestion;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\MatchingDebugModeService;
use App\Services\MatchingEngineService;
use App\Services\PersonalityProfileService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

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
            ->get(['id', 'phone', 'name', 'disabled', 'moderation_status', 'verify_status', 'is_synthetic', 'synthetic_batch']);

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
            ->get(['id', 'phone', 'name', 'verify_status', 'moderation_status']);

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
        $user->moderation_status = 'banned';
        $user->save();

        return response()->json(['ok' => true]);
    }

    public function reports(): JsonResponse
    {
        $items = ModerationReport::query()
            ->with([
                'reporter:id,name,phone',
                'targetUser:id,name,phone,disabled,moderation_status',
                'resolver:id,name,phone',
            ])
            ->orderByDesc('id')
            ->get()
            ->map(fn (ModerationReport $report) => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
                'category' => $report->category,
                'reason_code' => $report->reason_code,
                'detail' => $report->detail,
                'appeal_note' => $report->appeal_note,
                'appealed_at' => optional($report->appealed_at)?->toIso8601String(),
                'resolved_at' => optional($report->resolved_at)?->toIso8601String(),
                'reporter' => [
                    'id' => $report->reporter?->id,
                    'name' => $report->reporter?->name,
                    'phone' => $report->reporter?->phone,
                ],
                'target_user' => [
                    'id' => $report->targetUser?->id,
                    'name' => $report->targetUser?->name,
                    'phone' => $report->targetUser?->phone,
                    'disabled' => (bool) ($report->targetUser?->disabled ?? false),
                    'moderation_status' => (string) ($report->targetUser?->moderation_status ?? 'normal'),
                ],
                'resolver' => [
                    'id' => $report->resolver?->id,
                    'name' => $report->resolver?->name,
                ],
            ])
            ->values();

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function reportDetail(int $reportId): JsonResponse
    {
        $report = ModerationReport::query()
            ->with([
                'reporter:id,name,phone',
                'targetUser:id,name,phone,disabled,moderation_status',
                'resolver:id,name,phone',
            ])
            ->find($reportId);

        if (!$report) {
            return response()->json(['message' => 'report not found'], 404);
        }

        return response()->json([
            'id' => $report->id,
            'status' => $report->status,
            'appeal_status' => $report->appeal_status,
            'category' => $report->category,
            'reason_code' => $report->reason_code,
            'detail' => $report->detail,
            'appeal_note' => $report->appeal_note,
            'admin_note' => $report->admin_note,
            'appealed_at' => optional($report->appealed_at)?->toIso8601String(),
            'resolved_at' => optional($report->resolved_at)?->toIso8601String(),
            'reporter' => [
                'id' => $report->reporter?->id,
                'name' => $report->reporter?->name,
                'phone' => $report->reporter?->phone,
            ],
            'target_user' => [
                'id' => $report->targetUser?->id,
                'name' => $report->targetUser?->name,
                'phone' => $report->targetUser?->phone,
                'disabled' => (bool) ($report->targetUser?->disabled ?? false),
                'moderation_status' => (string) ($report->targetUser?->moderation_status ?? 'normal'),
            ],
            'resolver' => [
                'id' => $report->resolver?->id,
                'name' => $report->resolver?->name,
            ],
        ]);
    }

    public function reportAction(Request $request, int $reportId): JsonResponse
    {
        $data = $request->validate([
            'action' => ['required', 'string', 'in:triage,investigate,dismiss,restrict,banned,restore,close'],
            'note' => ['nullable', 'string', 'max:2000'],
        ]);

        $report = ModerationReport::query()->find($reportId);
        if (!$report) {
            return response()->json(['message' => 'report not found'], 404);
        }

        $actor = $request->user();
        $targetUser = User::find($report->target_user_id);

        $report->admin_note = $data['note'] ?? $report->admin_note;
        $report->resolved_by_user_id = (int) $actor->id;

        switch ($data['action']) {
            case 'triage':
                $report->status = 'triaged';
                break;
            case 'investigate':
                $report->status = 'investigating';
                break;
            case 'dismiss':
                $report->status = 'dismissed';
                $report->appeal_status = 'resolved';
                break;
            case 'restrict':
                $report->status = 'action_taken';
                if ($targetUser) {
                    $targetUser->moderation_status = 'restricted';
                    $targetUser->disabled = false;
                    $targetUser->save();
                }
                break;
            case 'banned':
                $report->status = 'action_taken';
                if ($targetUser) {
                    $targetUser->moderation_status = 'banned';
                    $targetUser->disabled = true;
                    $targetUser->save();
                }
                break;
            case 'restore':
                $report->status = 'closed';
                if ($targetUser) {
                    $targetUser->moderation_status = 'restored';
                    $targetUser->disabled = false;
                    $targetUser->save();
                }
                break;
            case 'close':
                $report->status = 'closed';
                break;
        }

        $report->resolved_at = now();
        $report->save();

        return response()->json([
            'ok' => true,
            'report' => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
            ],
        ]);
    }

    public function devRunMatching(
        PersonalityProfileService $profileService,
        MatchingEngineService $matchingEngine,
        MatchingDebugModeService $debugMode
    ): JsonResponse
    {
        // Dev matching may process large synthetic batches; avoid php max_execution_time cutoff.
        @set_time_limit(0);
        @ini_set('max_execution_time', '0');

        $weekTag = $this->weekTag();
        $totalQuestions = QuestionnaireQuestion::query()->where('enabled', true)->count();
        $requiredAnswers = max(1, (int) config('questionnaire.required_answer_count', 10));
        $includeSyntheticUsers = $debugMode->includeSyntheticUsers();

        if ($totalQuestions === 0) {
            return response()->json([
                'ok' => true,
                'week_tag' => $weekTag,
                'pairs' => 0,
                'eligible_users' => 0,
                'include_synthetic_users' => $includeSyntheticUsers,
                'message' => 'no enabled questions',
                'match_ids' => [],
            ]);
        }

        $eligibleUserIds = QuestionnaireAnswer::query()
            ->select('user_id')
            ->groupBy('user_id')
            ->havingRaw('COUNT(DISTINCT questionnaire_question_id) >= ?', [$requiredAnswers]);

        $users = User::query()
            ->where('disabled', false)
            ->when(!$includeSyntheticUsers, function ($q) {
                $q->where('is_synthetic', false);
            })
            ->whereIn('id', $eligibleUserIds)
            ->orderBy('id')
            ->get(['id', 'created_at', 'updated_at']);

        $pairs = 0;
        $createdMatchIds = [];
        $profiles = [];
        $usersMeta = [];
        foreach ($users as $u) {
            $profiles[(int) $u->id] = $profileService->buildForUser((int) $u->id);
            $usersMeta[(int) $u->id] = [
                'created_at' => $u->created_at,
                'updated_at' => $u->updated_at,
            ];
        }
        $plannedPairs = $matchingEngine->buildPairs($profiles, $usersMeta);

        foreach ($plannedPairs as $plannedPair) {
            $a = (int) $plannedPair['user_a'];
            $b = (int) $plannedPair['user_b'];

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
                'highlights' => (string) $plannedPair['highlights'],
                'explanation_tags' => $plannedPair['explanation_tags'] ?? null,
                'score_base' => $plannedPair['score_base'] ?? null,
                'score_final' => $plannedPair['score_final'] ?? null,
                'score_fair' => $plannedPair['score_fair'] ?? null,
                'score_personality_total' => $plannedPair['score_personality_total'] ?? null,
                'score_mbti_total' => $plannedPair['score_mbti_total'] ?? null,
                'score_astro_total' => $plannedPair['score_astro_total'] ?? null,
                'score_overall' => $plannedPair['score_overall'] ?? null,
                'score_bazi' => $plannedPair['score_bazi'] ?? null,
                'score_zodiac' => $plannedPair['score_zodiac'] ?? null,
                'score_constellation' => $plannedPair['score_constellation'] ?? null,
                'score_natal_chart' => $plannedPair['score_natal_chart'] ?? null,
                'match_verdict' => $plannedPair['match_verdict'] ?? null,
                'match_reasons' => $plannedPair['match_reasons'] ?? null,
                'penalty_factors' => $plannedPair['penalty_factors'] ?? null,
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
            'include_synthetic_users' => $includeSyntheticUsers,
            'match_ids' => $createdMatchIds,
        ]);
    }

    public function devMatchingDebugStatus(MatchingDebugModeService $debugMode): JsonResponse
    {
        $enabled = $debugMode->includeSyntheticUsers();
        $syntheticUserCount = User::query()->where('is_synthetic', true)->count();

        return response()->json([
            'ok' => true,
            'include_synthetic_users' => $enabled,
            'synthetic_users' => $syntheticUserCount,
        ]);
    }

    public function devMatchingDebugSwitch(Request $request, MatchingDebugModeService $debugMode): JsonResponse
    {
        $data = $request->validate([
            'include_synthetic_users' => ['required', 'boolean'],
        ]);

        $enabled = (bool) $data['include_synthetic_users'];
        $debugMode->setIncludeSyntheticUsers($enabled);

        return response()->json([
            'ok' => true,
            'include_synthetic_users' => $debugMode->includeSyntheticUsers(),
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

    public function questionQualityStats(): JsonResponse
    {
        $base = QuestionnaireQuestion::query()->where('enabled', true);

        $totalsByTier = (clone $base)
            ->selectRaw('quality_tier, COUNT(*) as c')
            ->groupBy('quality_tier')
            ->pluck('c', 'quality_tier');

        $totalsByTag = (clone $base)
            ->selectRaw('quality_tag, COUNT(*) as c')
            ->groupBy('quality_tag')
            ->pluck('c', 'quality_tag');

        $reasons = (clone $base)
            ->select(['quality_tier', 'quality_tag', 'quality_reason', DB::raw('COUNT(*) as c')])
            ->groupBy('quality_tier', 'quality_tag', 'quality_reason')
            ->orderByDesc('c')
            ->get()
            ->map(fn ($r) => [
                'quality_tier' => (string) $r->quality_tier,
                'quality_tag' => (string) $r->quality_tag,
                'quality_reason' => (string) $r->quality_reason,
                'count' => (int) $r->c,
            ])
            ->values();

        $dropReasons = $reasons
            ->filter(fn ($r) => $r['quality_tag'] === 'low_drop')
            ->values();

        return response()->json([
            'total' => (int) $base->count(),
            'by_tier' => $totalsByTier,
            'by_tag' => $totalsByTag,
            'reasons' => $reasons,
            'low_drop_reasons' => $dropReasons,
        ]);
    }

    public function pruneLowDropQuestions(Request $request): JsonResponse
    {
        $data = $request->validate([
            'dry_run' => ['nullable', 'boolean'],
            'reasons' => ['nullable', 'array'],
            'reasons.*' => ['string', 'max:64'],
        ]);

        $dryRun = (bool) ($data['dry_run'] ?? true);
        $reasons = array_values(array_filter(array_map('strval', (array) ($data['reasons'] ?? []))));

        $base = QuestionnaireQuestion::query()
            ->where('enabled', true)
            ->where('quality_tag', 'low_drop');

        if (!empty($reasons)) {
            $base->whereIn('quality_reason', $reasons);
        }

        $byReason = (clone $base)
            ->select(['quality_reason', DB::raw('COUNT(*) as c')])
            ->groupBy('quality_reason')
            ->orderByDesc('c')
            ->get()
            ->map(fn ($r) => [
                'quality_reason' => (string) $r->quality_reason,
                'count' => (int) $r->c,
            ])
            ->values();

        $candidates = (int) (clone $base)->count();
        $updated = 0;
        if (!$dryRun && $candidates > 0) {
            $updated = $base->update(['enabled' => false]);
        }

        return response()->json([
            'ok' => true,
            'dry_run' => $dryRun,
            'candidates' => $candidates,
            'updated' => (int) $updated,
            'reasons' => $reasons,
            'by_reason' => $byReason,
        ]);
    }
}
