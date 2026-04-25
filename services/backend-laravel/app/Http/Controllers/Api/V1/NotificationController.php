<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppNotificationItem;
use App\Services\NotificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    /**
     * @return array<string, mixed>
     */
    private function shapeNotification(AppNotificationItem $notification): array
    {
        $payload = (array) ($notification->payload ?? []);

        return [
            'id' => (int) $notification->id,
            'kind' => (string) $notification->kind,
            'title' => (string) $notification->title,
            'body' => (string) ($notification->body ?? ''),
            'payload' => $payload,
            'route_name' => (string) ($payload['route_name'] ?? ''),
            'route_args' => (array) ($payload['route_args'] ?? []),
            'read_at' => optional($notification->read_at)?->toISOString(),
            'expires_at' => optional($notification->expires_at)?->toISOString(),
            'created_at' => optional($notification->created_at)?->toISOString(),
            'updated_at' => optional($notification->updated_at)?->toISOString(),
            'is_read' => $notification->read_at !== null,
        ];
    }

    public function index(Request $request, NotificationService $notifications): JsonResponse
    {
        $items = $notifications->listForUser((int) $request->user()->id, 50);

        return response()->json([
            'ok' => true,
            'items' => $items->map(fn (AppNotificationItem $item) => $this->shapeNotification($item))->values(),
            'total' => $items->count(),
            'unread_total' => $items->whereNull('read_at')->count(),
        ]);
    }

    public function unreadCount(Request $request, NotificationService $notifications): JsonResponse
    {
        return response()->json([
            'ok' => true,
            'unread_total' => $notifications->unreadCount((int) $request->user()->id),
        ]);
    }

    public function markRead(Request $request, int $notificationId, NotificationService $notifications): JsonResponse
    {
        $notification = $notifications->markRead((int) $request->user()->id, $notificationId);

        if (!$notification) {
            return response()->json(['message' => 'notification not found'], 404);
        }

        $notification->forceFill(['read_at' => now()])->save();

        Log::info('notification_marked_read', [
            'notification_id' => (int) $notification->id,
            'user_id' => (int) $request->user()->id,
        ]);

        return response()->json([
            'ok' => true,
            'notification_id' => $notification->id,
        ]);
    }

    public function markAllRead(Request $request, NotificationService $notifications): JsonResponse
    {
        $affected = $notifications->markAllRead((int) $request->user()->id);

        Log::info('notification_marked_all_read', [
            'user_id' => (int) $request->user()->id,
            'affected' => $affected,
        ]);

        return response()->json([
            'ok' => true,
            'affected' => $affected,
        ]);
    }
}
