<?php

namespace App\Services;

use App\Models\AppNotificationItem;
use Illuminate\Database\Eloquent\Collection;

class NotificationService
{
    private function payloadSignature(array $payload): string
    {
        return json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES) ?: '{}';
    }

    public function createForUser(
        int $userId,
        string $kind,
        string $title,
        ?string $body = null,
        array $payload = [],
        ?string $expiresAt = null,
    ): AppNotificationItem {
        $normalizedKind = mb_substr(trim($kind), 0, 32);
        $normalizedTitle = mb_substr(trim($title), 0, 120);
        $normalizedBody = $body !== null ? trim($body) : null;
        $payloadSignature = $this->payloadSignature($payload);

        $existing = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->where('kind', $normalizedKind)
            ->where('title', $normalizedTitle)
            ->where(function ($query) use ($normalizedBody) {
                if ($normalizedBody === null) {
                    $query->whereNull('body');
                    return;
                }
                $query->where('body', $normalizedBody);
            })
            ->whereRaw('payload = ?', [$payloadSignature])
            ->where('created_at', '>=', now()->subMinutes(5))
            ->first();

        if ($existing) {
            return $existing;
        }

        return AppNotificationItem::query()->create([
            'user_id' => $userId,
            'kind' => $normalizedKind,
            'title' => $normalizedTitle,
            'body' => $normalizedBody,
            'payload' => $payload,
            'read_at' => null,
            'expires_at' => $expiresAt,
        ]);
    }

    /**
     * @return Collection<int, AppNotificationItem>
     */
    public function listForUser(int $userId, int $limit = 50): Collection
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->orderByDesc('id')
            ->limit($limit)
            ->get();
    }

    public function unreadCount(int $userId): int
    {
        return (int) AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->count();
    }

    public function markRead(int $userId, int $notificationId): ?AppNotificationItem
    {
        $notification = AppNotificationItem::query()
            ->where('user_id', $userId)
            ->find($notificationId);

        if (!$notification) {
            return null;
        }

        if ($notification->read_at === null) {
            $notification->forceFill(['read_at' => now()])->save();
        }

        return $notification;
    }

    public function markAllRead(int $userId): int
    {
        return AppNotificationItem::query()
            ->where('user_id', $userId)
            ->whereNull('read_at')
            ->update(['read_at' => now()]);
    }
}
