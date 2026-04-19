<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ModerationReport;
use App\Models\User;
use App\Models\UserBlock;
use App\Services\EventLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ModerationController extends Controller
{
    private function currentUserId(Request $request): int
    {
        return (int) $request->user()->id;
    }

    public function report(Request $request, EventLogger $events): JsonResponse
    {
        $data = $request->validate([
            'target_user_id' => ['required', 'integer', 'exists:users,id'],
            'target_message_id' => ['nullable', 'integer', 'exists:chat_messages,id'],
            'target_status_post_id' => ['nullable', 'integer', 'exists:status_posts,id'],
            'category' => ['required', 'string', 'in:user,message,match,profile,status_post,other'],
            'reason_code' => ['required', 'string', 'max:64'],
            'detail' => ['nullable', 'string', 'max:2000'],
        ]);

        $reporterId = $this->currentUserId($request);
        $targetUserId = (int) $data['target_user_id'];
        if ($reporterId === $targetUserId) {
            return response()->json(['message' => 'cannot report self'], 422);
        }

        $report = ModerationReport::create([
            'reporter_id' => $reporterId,
            'target_user_id' => $targetUserId,
            'target_message_id' => $data['target_message_id'] ?? null,
            'target_status_post_id' => $data['target_status_post_id'] ?? null,
            'category' => $data['category'],
            'reason_code' => $data['reason_code'],
            'detail' => $data['detail'] ?? null,
            'status' => 'new',
            'appeal_status' => 'none',
        ]);

        $events->log(
            eventName: 'report_submit',
            actorUserId: $reporterId,
            targetUserId: $targetUserId,
            payload: [
                'category' => (string) $data['category'],
                'reason_code' => (string) $data['reason_code'],
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        return response()->json([
            'ok' => true,
            'report' => [
                'id' => $report->id,
                'status' => $report->status,
                'appeal_status' => $report->appeal_status,
            ],
        ]);
    }

    public function appeal(Request $request, int $reportId): JsonResponse
    {
        $data = $request->validate([
            'appeal_note' => ['required', 'string', 'max:2000'],
        ]);

        $report = ModerationReport::query()
            ->where('id', $reportId)
            ->where('reporter_id', $this->currentUserId($request))
            ->first();

        if (!$report) {
            return response()->json(['message' => 'report not found'], 404);
        }

        $report->appeal_status = 'submitted';
        $report->appeal_note = $data['appeal_note'];
        $report->appealed_at = now();
        $report->save();

        return response()->json([
            'ok' => true,
            'report' => [
                'id' => $report->id,
                'appeal_status' => $report->appeal_status,
            ],
        ]);
    }

    public function blocks(Request $request): JsonResponse
    {
        $items = UserBlock::query()
            ->with(['blockedUser:id,name,phone'])
            ->where('blocker_id', $this->currentUserId($request))
            ->orderByDesc('id')
            ->get()
            ->map(fn (UserBlock $block) => [
                'id' => $block->id,
                'blocked_user_id' => $block->blocked_user_id,
                'blocked_user_name' => $block->blockedUser?->name ?? '',
                'blocked_user_phone' => $block->blockedUser?->phone ?? '',
                'reason_code' => $block->reason_code,
                'detail' => $block->detail,
                'created_at' => optional($block->created_at)?->toIso8601String(),
            ])
            ->values();

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function block(Request $request, EventLogger $events): JsonResponse
    {
        $data = $request->validate([
            'blocked_user_id' => ['required', 'integer', 'exists:users,id'],
            'reason_code' => ['nullable', 'string', 'max:64'],
            'detail' => ['nullable', 'string', 'max:2000'],
        ]);

        $blockerId = $this->currentUserId($request);
        $blockedUserId = (int) $data['blocked_user_id'];
        if ($blockerId === $blockedUserId) {
            return response()->json(['message' => 'cannot block self'], 422);
        }

        $block = UserBlock::query()->firstOrCreate(
            [
                'blocker_id' => $blockerId,
                'blocked_user_id' => $blockedUserId,
            ],
            [
                'reason_code' => $data['reason_code'] ?? null,
                'detail' => $data['detail'] ?? null,
            ]
        );

        $events->log(
            eventName: 'block_submit',
            actorUserId: $blockerId,
            targetUserId: $blockedUserId,
            payload: [
                'reason_code' => (string) ($data['reason_code'] ?? ''),
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        return response()->json([
            'ok' => true,
            'block' => [
                'id' => $block->id,
                'blocked_user_id' => $block->blocked_user_id,
            ],
        ]);
    }

    public function unblock(Request $request, int $blockedUserId): JsonResponse
    {
        $deleted = UserBlock::query()
            ->where('blocker_id', $this->currentUserId($request))
            ->where('blocked_user_id', $blockedUserId)
            ->delete();

        return response()->json([
            'ok' => true,
            'deleted' => $deleted,
        ]);
    }
}
