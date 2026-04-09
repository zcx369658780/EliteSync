<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\UserBlock;
use App\Models\User;
use App\Services\EventLogger;
use App\Services\MatchingDebugModeService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    private function roomId(int $a, int $b): string
    {
        $x = min($a, $b);
        $y = max($a, $b);

        return "{$x}_{$y}";
    }

    private function canChat(int $userId, int $peerId): bool
    {
        if ($this->blockedByModeration($userId, $peerId)) {
            return false;
        }

        $includeSyntheticUsers = app(MatchingDebugModeService::class)->includeSyntheticUsers();
        if (!$includeSyntheticUsers) {
            $peerSynthetic = (bool) User::query()->where('id', $peerId)->value('is_synthetic');
            if ($peerSynthetic) {
                return false;
            }
        }

        return DatingMatch::query()
            ->where('drop_released', true)
            ->where(function ($q) use ($userId, $peerId) {
                $q->where(function ($pair) use ($userId, $peerId) {
                    $pair->where('user_a', $userId)->where('user_b', $peerId);
                })->orWhere(function ($pair) use ($userId, $peerId) {
                    $pair->where('user_a', $peerId)->where('user_b', $userId);
                });
            })
            ->exists();
    }

    private function blockedByModeration(int $userId, int $peerId): bool
    {
        return UserBlock::query()
            ->where(function ($q) use ($userId, $peerId) {
                $q->where('blocker_id', $userId)->where('blocked_user_id', $peerId);
            })
            ->orWhere(function ($q) use ($userId, $peerId) {
                $q->where('blocker_id', $peerId)->where('blocked_user_id', $userId);
            })
            ->exists();
    }

    public function send(Request $request, EventLogger $events): JsonResponse
    {
        $data = $request->validate([
            'receiver_id' => ['required', 'integer', 'exists:users,id'],
            'content' => ['required', 'string', 'max:5000'],
        ]);

        $user = $request->user();
        $receiverId = (int) $data['receiver_id'];

        if ($receiverId === (int) $user->id) {
            return response()->json(['message' => 'cannot message self'], 422);
        }

        if ($this->blockedByModeration((int) $user->id, $receiverId)) {
            return response()->json(['message' => 'chat blocked by moderation'], 403);
        }

        if (!$this->canChat((int) $user->id, $receiverId)) {
            return response()->json(['message' => 'chat not allowed before matching'], 403);
        }

        $message = ChatMessage::create([
            'room_id' => $this->roomId((int) $user->id, $receiverId),
            'sender_id' => $user->id,
            'receiver_id' => $receiverId,
            'content' => trim($data['content']),
        ]);

        $events->log(
            eventName: 'message_sent',
            actorUserId: (int) $user->id,
            targetUserId: $receiverId,
            payload: [
                'message_id' => (int) $message->id,
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        return response()->json([
            'id' => $message->id,
            'ok' => true,
        ]);
    }

    public function list(Request $request): JsonResponse
    {
        $data = $request->validate([
            'peer_id' => ['required', 'integer', 'exists:users,id'],
            'after_id' => ['nullable', 'integer', 'min:0'],
            'limit' => ['nullable', 'integer', 'min:1', 'max:100'],
        ]);

        $user = $request->user();
        $peerId = (int) $data['peer_id'];

        if ($this->blockedByModeration((int) $user->id, $peerId)) {
            return response()->json(['message' => 'chat blocked by moderation'], 403);
        }

        if (!$this->canChat((int) $user->id, $peerId)) {
            return response()->json(['message' => 'chat not allowed before matching'], 403);
        }

        $afterId = (int) ($data['after_id'] ?? 0);
        $limit = (int) ($data['limit'] ?? 50);
        $roomId = $this->roomId((int) $user->id, $peerId);

        // Pulling conversation acts as read receipt for incoming unread messages.
        ChatMessage::query()
            ->where('room_id', $roomId)
            ->where('sender_id', $peerId)
            ->where('receiver_id', (int) $user->id)
            ->where('is_read', false)
            ->update([
                'is_read' => true,
                'read_at' => now(),
            ]);

        $items = ChatMessage::query()
            ->where('room_id', $roomId)
            ->where('id', '>', $afterId)
            ->orderBy('id')
            ->limit($limit)
            ->get(['id', 'sender_id', 'receiver_id', 'content', 'is_read', 'created_at']);

        return response()->json([
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function markRead(Request $request, int $messageId): JsonResponse
    {
        /** @var User $user */
        $user = $request->user();
        $message = ChatMessage::find($messageId);

        if (!$message || (int) $message->receiver_id !== (int) $user->id) {
            return response()->json(['message' => 'message not found'], 404);
        }

        if (!$message->is_read) {
            $message->is_read = true;
            $message->read_at = now();
            $message->save();
        }

        return response()->json(['ok' => true]);
    }

    public function websocketStub(int $userId): JsonResponse
    {
        return response()->json([
            'message' => 'websocket gateway available via artisan chat:ws',
            'user_id' => $userId,
            'ws_url_example' => "ws://127.0.0.1:8081/api/v1/messages/ws/{$userId}",
        ], 501);
    }
}
