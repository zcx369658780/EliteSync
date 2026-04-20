<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\AppNotificationItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class NotificationController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $items = AppNotificationItem::query()
            ->where('user_id', $request->user()->id)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return response()->json([
            'ok' => true,
            'items' => $items,
            'total' => $items->count(),
            'unread_total' => $items->whereNull('read_at')->count(),
        ]);
    }

    public function markRead(Request $request, int $notificationId): JsonResponse
    {
        $notification = AppNotificationItem::query()
            ->where('user_id', $request->user()->id)
            ->find($notificationId);

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
}
