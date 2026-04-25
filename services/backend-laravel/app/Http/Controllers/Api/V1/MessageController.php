<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\ChatMessage;
use App\Models\DatingMatch;
use App\Models\MessageAttachment;
use App\Models\MediaAsset;
use App\Models\UserBlock;
use App\Models\User;
use App\Services\EventLogger;
use App\Services\ConversationDomainService;
use App\Services\NotificationService;
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

    /**
     * @return array<string, mixed>
     */
    private function shapeAttachment(MessageAttachment $attachment): array
    {
        $asset = $attachment->mediaAsset;

        return [
            'id' => (int) $attachment->id,
            'attachment_type' => (string) $attachment->attachment_type,
            'sort_order' => (int) $attachment->sort_order,
            'metadata' => $attachment->metadata ?? null,
            'media_asset' => $asset ? [
                'id' => (int) $asset->id,
                'owner_user_id' => (int) $asset->owner_user_id,
                'media_type' => (string) $asset->media_type,
                'storage_provider' => (string) $asset->storage_provider,
                'storage_disk' => (string) $asset->storage_disk,
                'storage_key' => (string) $asset->storage_key,
                'mime_type' => $asset->mime_type,
                'size_bytes' => (int) $asset->size_bytes,
                'width' => $asset->width,
                'height' => $asset->height,
                'duration_ms' => $asset->duration_ms,
                'status' => (string) $asset->status,
                'error_code' => $asset->error_code,
                'error_message' => $asset->error_message,
                'public_url' => $asset->public_url,
                'metadata' => $asset->metadata ?? null,
                'uploaded_at' => optional($asset->uploaded_at)?->toISOString(),
                'processed_at' => optional($asset->processed_at)?->toISOString(),
            ] : null,
        ];
    }

    /**
     * @return array<string, mixed>
     */
    private function shapeMessage(ChatMessage $message): array
    {
        $message->loadMissing(['attachments.mediaAsset']);

        $attachments = $message->attachments
            ->sortBy('sort_order')
            ->values()
            ->map(fn (MessageAttachment $attachment) => $this->shapeAttachment($attachment))
            ->all();
        $hasVideoAttachments = collect($attachments)->contains(function (array $attachment): bool {
            $mediaType = (string) ($attachment['media_asset']['media_type'] ?? '');

            return str_starts_with($mediaType, 'video') || $mediaType === 'video';
        });
        $hasImageAttachments = collect($attachments)->contains(function (array $attachment): bool {
            $mediaType = (string) ($attachment['media_asset']['media_type'] ?? '');

            return str_starts_with($mediaType, 'image') || $mediaType === 'image';
        });

        return [
            'id' => (int) $message->id,
            'room_id' => (string) $message->room_id,
            'sender_id' => (int) $message->sender_id,
            'receiver_id' => (int) $message->receiver_id,
            'content' => (string) $message->content,
            'is_read' => (bool) $message->is_read,
            'read_at' => optional($message->read_at)?->toISOString(),
            'created_at' => optional($message->created_at)?->toISOString(),
            'message_type' => $hasVideoAttachments
                ? 'video'
                : ($hasImageAttachments ? 'image' : (!empty($attachments) ? 'media' : 'text')),
            'has_attachments' => !empty($attachments),
            'attachments' => $attachments,
        ];
    }

    private function messageNotificationBody(ChatMessage $message): string
    {
        $message->loadMissing(['attachments.mediaAsset']);
        $attachments = $message->attachments;
        $hasVideoAttachments = $attachments->contains(function (MessageAttachment $attachment): bool {
            $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
            return str_starts_with($mediaType, 'video') || $mediaType === 'video';
        });
        $hasImageAttachments = $attachments->contains(function (MessageAttachment $attachment): bool {
            $mediaType = (string) ($attachment->mediaAsset?->media_type ?? '');
            return str_starts_with($mediaType, 'image') || $mediaType === 'image';
        });
        $content = trim((string) $message->content);

        if ($content !== '') {
            return mb_strimwidth($content, 0, 90, '…', 'UTF-8');
        }

        if ($hasVideoAttachments) {
            return '发送了一条视频消息';
        }

        if ($hasImageAttachments) {
            return '发送了一条图片消息';
        }

        if ($attachments->isNotEmpty()) {
            return '发送了一条多媒体消息';
        }

        return '发送了一条新消息';
    }

    public function send(
        Request $request,
        EventLogger $events,
        ConversationDomainService $conversationService,
        NotificationService $notifications
    ): JsonResponse
    {
        $data = $request->validate([
            'receiver_id' => ['required', 'integer', 'exists:users,id'],
            'content' => ['nullable', 'string', 'max:5000'],
            'attachment_ids' => ['nullable', 'array'],
            'attachment_ids.*' => ['integer', 'distinct'],
        ]);

        $user = $request->user();
        $receiverId = (int) $data['receiver_id'];
        $content = trim((string) ($data['content'] ?? ''));
        $attachmentIds = array_values(array_unique(array_map('intval', $data['attachment_ids'] ?? [])));

        if ($receiverId === (int) $user->id) {
            return response()->json(['message' => 'cannot message self'], 422);
        }

        if ($this->blockedByModeration((int) $user->id, $receiverId)) {
            return response()->json(['message' => 'chat blocked by moderation'], 403);
        }

        if (!$this->canChat((int) $user->id, $receiverId)) {
            return response()->json(['message' => 'chat not allowed before matching'], 403);
        }

        if ($content === '' && empty($attachmentIds)) {
            return response()->json([
                'message' => 'content or attachment_ids is required',
            ], 422);
        }

        $message = ChatMessage::create([
            'room_id' => $this->roomId((int) $user->id, $receiverId),
            'sender_id' => $user->id,
            'receiver_id' => $receiverId,
            'content' => $content,
        ]);

        if (!empty($attachmentIds)) {
            /** @var \Illuminate\Support\Collection<int, MediaAsset> $assets */
            $assets = MediaAsset::query()
                ->where('owner_user_id', $user->id)
                ->whereIn('id', $attachmentIds)
                ->orderBy('id')
                ->get();

            if ($assets->count() !== count($attachmentIds)) {
                $message->delete();

                return response()->json([
                    'message' => 'one or more attachments are invalid',
                ], 422);
            }

            foreach ($assets->values() as $index => $asset) {
                MessageAttachment::query()->create([
                    'message_id' => $message->id,
                    'media_asset_id' => $asset->id,
                    'attachment_type' => str_starts_with((string) $asset->media_type, 'video') || (string) $asset->media_type === 'video'
                        ? 'video'
                        : (str_starts_with((string) $asset->media_type, 'image') || (string) $asset->media_type === 'image' ? 'image' : 'media'),
                    'sort_order' => $index,
                    'metadata' => [
                        'media_type' => (string) $asset->media_type,
                        'status' => (string) $asset->status,
                    ],
                ]);
            }
        }

        $conversationService->syncFromMessage($message);
        $message->loadMissing(['attachments.mediaAsset']);

        $events->log(
            eventName: 'message_sent',
            actorUserId: (int) $user->id,
            targetUserId: $receiverId,
            payload: [
                'message_id' => (int) $message->id,
                'attachment_count' => count($attachmentIds),
                'app_version' => (string) $request->header('X-App-Version', 'unknown'),
                'source_page' => (string) $request->header('X-Source-Page', 'unknown'),
            ]
        );

        $senderName = trim((string) ($user->nickname ?? $user->name ?? $user->phone ?? '有人'));
        $notifications->createForUser(
            userId: $receiverId,
            kind: 'message',
            title: "{$senderName} 发来一条消息",
            body: $this->messageNotificationBody($message),
            payload: [
                'route_name' => 'chat_room',
                'route_args' => [
                    'conversation_id' => (string) $receiverId,
                    'title' => $senderName,
                ],
                'message_id' => (int) $message->id,
                'peer_user_id' => $receiverId,
                'source' => 'message',
            ]
        );

        return response()->json([
            'id' => $message->id,
            'ok' => true,
            'message' => $this->shapeMessage($message),
        ]);
    }

    public function list(Request $request, ConversationDomainService $conversationService): JsonResponse
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

        $lastMessage = ChatMessage::query()
            ->where('room_id', $roomId)
            ->orderByDesc('id')
            ->first();
        if ($lastMessage) {
            $conversationService->markReadForPair((int) $user->id, $peerId, (int) $lastMessage->id);
        }

        $items = ChatMessage::query()
            ->with(['attachments.mediaAsset'])
            ->where('room_id', $roomId)
            ->where('id', '>', $afterId)
            ->orderBy('id')
            ->limit($limit)
            ->get(['id', 'sender_id', 'receiver_id', 'content', 'is_read', 'created_at']);

        return response()->json([
            'items' => $items->map(fn (ChatMessage $message) => $this->shapeMessage($message))->values(),
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
