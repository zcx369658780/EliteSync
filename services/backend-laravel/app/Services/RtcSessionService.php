<?php

namespace App\Services;

use App\Models\DatingMatch;
use App\Models\RtcSession;
use App\Models\RtcSessionEvent;
use App\Models\User;
use App\Models\UserBlock;
use Illuminate\Database\Eloquent\Collection;
use Illuminate\Support\Carbon;
use Illuminate\Support\Str;

class RtcSessionService
{
    private const ACTIVE_STATUSES = ['calling', 'ringing', 'connecting', 'in_call'];
    private const TERMINAL_STATUSES = ['rejected', 'missed', 'busy', 'ended', 'failed'];
    private const INVITE_TIMEOUT_SECONDS = 10;
    private const DISCONNECT_TIMEOUT_SECONDS = 30;

    public function roomKey(int $a, int $b): string
    {
        $x = min($a, $b);
        $y = max($a, $b);

        return "{$x}_{$y}";
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

    public function canCall(int $userId, int $peerId): bool
    {
        if ($userId <= 0 || $peerId <= 0 || $userId === $peerId) {
            return false;
        }

        if ($this->blockedByModeration($userId, $peerId)) {
            return false;
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

    public function findForUser(int $userId, int $sessionId): ?RtcSession
    {
        return RtcSession::query()
            ->with(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user'])
            ->where('id', $sessionId)
            ->where(function ($query) use ($userId) {
                $query->where('initiator_user_id', $userId)->orWhere('peer_user_id', $userId);
            })
            ->first();
    }

    /**
     * @return Collection<int, RtcSession>
     */
    public function listForUser(int $userId, int $limit = 20): Collection
    {
        return RtcSession::query()
            ->with(['initiator', 'peer', 'acceptedBy', 'endedBy'])
            ->where(function ($query) use ($userId) {
                $query->where('initiator_user_id', $userId)->orWhere('peer_user_id', $userId);
            })
            ->orderByDesc('id')
            ->limit($limit)
            ->get()
            ->map(fn (RtcSession $session) => $this->refreshExpiredSession($session))
            ->values();
    }

    public function createCall(int $callerId, int $peerId, string $mode = 'voice'): RtcSession
    {
        $normalizedMode = in_array($mode, ['voice', 'video'], true) ? $mode : 'voice';
        if (!$this->canCall($callerId, $peerId)) {
            abort(403, 'call not allowed before matching');
        }
        $pairActive = RtcSession::query()
            ->where(function ($query) use ($callerId, $peerId) {
                $query->where(function ($pair) use ($callerId, $peerId) {
                    $pair->where('initiator_user_id', $callerId)->where('peer_user_id', $peerId);
                })->orWhere(function ($pair) use ($callerId, $peerId) {
                    $pair->where('initiator_user_id', $peerId)->where('peer_user_id', $callerId);
                });
            })
            ->whereIn('status', self::ACTIVE_STATUSES)
            ->latest('id')
            ->first();

        if ($pairActive) {
            $pairActive = $this->refreshExpiredSession($pairActive->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
            if (!in_array((string) $pairActive->status, self::ACTIVE_STATUSES, true)) {
                $pairActive = null;
            }
        }

        $session = RtcSession::query()->create([
            'call_key' => (string) Str::uuid(),
            'room_key' => $this->roomKey($callerId, $peerId),
            'initiator_user_id' => $callerId,
            'peer_user_id' => $peerId,
            'mode' => $normalizedMode,
            'status' => $pairActive ? 'busy' : 'calling',
            'ringing_at' => $pairActive ? null : now(),
            'accepted_at' => null,
            'started_at' => null,
            'ended_at' => $pairActive ? now() : null,
            'expires_at' => $pairActive ? now()->addMinutes(1) : now()->addSeconds(self::INVITE_TIMEOUT_SECONDS),
            'failure_code' => $pairActive ? 'peer_busy' : null,
            'failure_message' => $pairActive ? '对方正在通话中' : null,
            'metadata' => [
                'mode' => $normalizedMode,
                'call_kind' => $normalizedMode,
                'state_surface' => 'rtc_46',
            ],
        ]);

        $this->logEvent($session, $callerId, $pairActive ? 'busy' : 'created', [
            'mode' => $normalizedMode,
            'peer_busy' => (bool) $pairActive,
        ]);

        if (!$pairActive) {
            $caller = User::query()->find($callerId);
            $this->notifyPeer(
                $peerId,
                'rtc_call_invite',
                '语音来电',
                $caller ? ($caller->name ?: '好友') . ' 正在邀请你语音通话' : '你有一条语音来电',
                $session,
                [
                    'event' => 'incoming_call',
                    'mode' => $normalizedMode,
                ]
            );
        }

        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function acceptCall(RtcSession $session, int $userId): RtcSession
    {
        $this->assertParticipant($session, $userId);
        $this->assertMutable($session);
        if ((int) $session->peer_user_id !== $userId) {
            abort(403, 'only callee can accept');
        }

        $session->forceFill([
            'status' => 'connecting',
            'accepted_by_user_id' => $userId,
            'accepted_at' => now(),
            'peer_last_seen_at' => $userId === (int) $session->peer_user_id ? now() : $session->peer_last_seen_at,
            'initiator_last_seen_at' => $userId === (int) $session->initiator_user_id ? now() : $session->initiator_last_seen_at,
        ])->save();

        $this->logEvent($session, $userId, 'accepted');
        $this->notifyCounterpart($session, $userId, 'rtc_call_accepted', '通话已接听', '对方已接听通话');

        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function connectCall(RtcSession $session, int $userId): RtcSession
    {
        $this->assertParticipant($session, $userId);
        $this->assertMutable($session);

        $heartbeatAt = now();
        $session->forceFill([
            'status' => 'in_call',
            'started_at' => $session->started_at ?? now(),
            'expires_at' => now()->addMinutes(30),
            'initiator_last_seen_at' => $userId === (int) $session->initiator_user_id
                ? $heartbeatAt
                : $session->initiator_last_seen_at,
            'peer_last_seen_at' => $userId === (int) $session->peer_user_id
                ? $heartbeatAt
                : $session->peer_last_seen_at,
        ])->save();

        $this->logEvent($session, $userId, 'connected');
        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function heartbeatCall(RtcSession $session, int $userId): RtcSession
    {
        $this->assertParticipant($session, $userId);
        if (in_array((string) $session->status, self::TERMINAL_STATUSES, true)) {
            return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
        }

        $heartbeatAt = now();
        $session->forceFill([
            'initiator_last_seen_at' => $userId === (int) $session->initiator_user_id
                ? $heartbeatAt
                : $session->initiator_last_seen_at,
            'peer_last_seen_at' => $userId === (int) $session->peer_user_id
                ? $heartbeatAt
                : $session->peer_last_seen_at,
        ])->save();

        $this->logEvent($session, $userId, 'heartbeat', [
            'side' => (int) $session->initiator_user_id === $userId ? 'initiator' : 'peer',
        ]);

        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function rejectCall(RtcSession $session, int $userId): RtcSession
    {
        $this->assertParticipant($session, $userId);
        $this->assertMutable($session);
        if ((int) $session->peer_user_id !== $userId) {
            abort(403, 'only callee can reject');
        }

        $session->forceFill([
            'status' => 'rejected',
            'ended_by_user_id' => $userId,
            'ended_at' => now(),
            'failure_code' => 'rejected',
            'failure_message' => '通话已被拒绝',
        ])->save();

        $this->logEvent($session, $userId, 'rejected');
        $this->notifyCounterpart($session, $userId, 'rtc_call_rejected', '通话已拒绝', '对方拒绝了通话邀请');

        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function endCall(RtcSession $session, int $userId): RtcSession
    {
        $this->assertParticipant($session, $userId);
        if (!in_array((string) $session->status, array_merge(self::ACTIVE_STATUSES, ['busy']), true)) {
            return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
        }

        $session->forceFill([
            'status' => 'ended',
            'ended_by_user_id' => $userId,
            'ended_at' => now(),
            'failure_code' => null,
            'failure_message' => null,
        ])->save();

        $this->logEvent($session, $userId, 'ended');
        $this->notifyCounterpart($session, $userId, 'rtc_call_ended', '通话已结束', '对方结束了通话');

        return $this->refreshExpiredSession($session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
    }

    public function refreshExpiredSession(RtcSession $session): RtcSession
    {
        if (!in_array((string) $session->status, ['calling', 'ringing', 'connecting', 'in_call'], true)) {
            return $session;
        }

        $disconnected = $this->detectedDisconnectedParticipants($session);
        if ($disconnected !== []) {
            $endedByUserId = count($disconnected) === 1 ? $disconnected[0] : null;
            $session->forceFill([
                'status' => 'ended',
                'ended_by_user_id' => $endedByUserId,
                'ended_at' => $session->ended_at ?? now(),
                'failure_code' => 'peer_disconnected',
                'failure_message' => '对方已断开连接',
            ])->save();

            $this->logEvent($session, $endedByUserId, 'disconnected', [
                'reason' => 'heartbeat_timeout',
                'disconnected_user_ids' => $disconnected,
            ]);

            return $session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']);
        }

        if ($session->expires_at && $session->expires_at->isFuture()) {
            return $session;
        }

        $isConversationStarted = in_array((string) $session->status, ['connecting', 'in_call'], true);
        $session->forceFill([
            'status' => $isConversationStarted ? 'failed' : 'missed',
            'ended_at' => $session->ended_at ?? now(),
            'failure_code' => 'timeout',
            'failure_message' => $isConversationStarted ? '通话已超时' : '未接通',
        ])->save();

        if ($isConversationStarted) {
            $this->logEvent($session, $session->initiator_user_id, 'failed', [
                'reason' => 'timeout',
            ]);
        } else {
            $this->logEvent($session, $session->initiator_user_id, 'missed', [
                'reason' => 'timeout',
            ]);
            $this->notifyCounterpart($session, (int) $session->peer_user_id, 'rtc_call_missed', '未接通', '语音通话未接通');
        }

        return $session->fresh(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']);
    }

    /**
     * @return array<int>
     */
    private function detectedDisconnectedParticipants(RtcSession $session): array
    {
        if (!in_array((string) $session->status, ['connecting', 'in_call'], true)) {
            return [];
        }

        $threshold = now()->subSeconds(self::DISCONNECT_TIMEOUT_SECONDS);
        $disconnected = [];

        $initiatorLastSeen = $session->initiator_last_seen_at;
        if ($initiatorLastSeen instanceof Carbon) {
            if ($initiatorLastSeen->lessThan($threshold)) {
                $disconnected[] = (int) $session->initiator_user_id;
            }
        } elseif ($session->started_at instanceof Carbon || $session->accepted_at instanceof Carbon) {
            $reference = $session->started_at ?? $session->accepted_at;
            if ($reference && $reference->lessThan($threshold)) {
                $disconnected[] = (int) $session->initiator_user_id;
            }
        }

        $peerLastSeen = $session->peer_last_seen_at;
        if ($peerLastSeen instanceof Carbon) {
            if ($peerLastSeen->lessThan($threshold)) {
                $disconnected[] = (int) $session->peer_user_id;
            }
        } elseif ($session->started_at instanceof Carbon || $session->accepted_at instanceof Carbon) {
            $reference = $session->started_at ?? $session->accepted_at;
            if ($reference && $reference->lessThan($threshold)) {
                $disconnected[] = (int) $session->peer_user_id;
            }
        }

        return array_values(array_unique($disconnected));
    }

    /**
     * @return array<string, mixed>
     */
    public function summarizeSession(RtcSession $session, int $viewerId): array
    {
        $session = $this->refreshExpiredSession($session->loadMissing(['initiator', 'peer', 'acceptedBy', 'endedBy', 'events.user']));
        $peer = (int) $session->initiator_user_id === $viewerId ? $session->peer : $session->initiator;
        $initiator = $session->initiator;
        $events = $session->events
            ->sortBy('id')
            ->values()
            ->map(fn (RtcSessionEvent $event) => [
                'id' => (int) $event->id,
                'event_name' => (string) $event->event_name,
                'user_id' => $event->user_id,
                'payload' => $event->payload ?? [],
                'created_at' => optional($event->created_at)?->toISOString(),
            ])
            ->all();

        return [
            'id' => (int) $session->id,
            'call_key' => (string) $session->call_key,
            'room_key' => (string) $session->room_key,
            'mode' => (string) $session->mode,
            'status' => (string) $session->status,
            'title' => $this->modeLabel((string) $session->mode),
            'initiator_user_id' => (int) $session->initiator_user_id,
            'peer_user_id' => (int) $session->peer_user_id,
            'initiator_name' => $this->displayNameForUser($initiator),
            'peer_name' => $this->displayNameForUser($peer),
            'is_initiator' => (int) $session->initiator_user_id === $viewerId,
            'accepted_by_user_id' => $session->accepted_by_user_id,
            'ended_by_user_id' => $session->ended_by_user_id,
            'failure_code' => $session->failure_code,
            'failure_message' => $session->failure_message,
            'ringing_at' => optional($session->ringing_at)?->toISOString(),
            'accepted_at' => optional($session->accepted_at)?->toISOString(),
            'started_at' => optional($session->started_at)?->toISOString(),
            'initiator_last_seen_at' => optional($session->initiator_last_seen_at)?->toISOString(),
            'peer_last_seen_at' => optional($session->peer_last_seen_at)?->toISOString(),
            'ended_at' => optional($session->ended_at)?->toISOString(),
            'expires_at' => optional($session->expires_at)?->toISOString(),
            'created_at' => optional($session->created_at)?->toISOString(),
            'updated_at' => optional($session->updated_at)?->toISOString(),
            'latest_event_name' => $session->events->last()?->event_name,
            'events' => $events,
            'is_active' => in_array((string) $session->status, self::ACTIVE_STATUSES, true),
            'is_terminal' => in_array((string) $session->status, self::TERMINAL_STATUSES, true),
        ];
    }

    private function assertParticipant(RtcSession $session, int $userId): void
    {
        if ((int) $session->initiator_user_id !== $userId && (int) $session->peer_user_id !== $userId) {
            abort(404, 'call not found');
        }
    }

    private function assertMutable(RtcSession $session): void
    {
        if (in_array((string) $session->status, self::TERMINAL_STATUSES, true)) {
            abort(409, 'call already finished');
        }
    }

    private function logEvent(RtcSession $session, ?int $userId, string $eventName, array $payload = []): void
    {
        RtcSessionEvent::query()->create([
            'rtc_session_id' => $session->id,
            'user_id' => $userId,
            'event_name' => $eventName,
            'payload' => $payload,
        ]);
    }

    private function notifyPeer(int $peerId, string $kind, string $title, string $body, RtcSession $session, array $payload = []): void
    {
        app(NotificationService::class)->createForUser(
            $peerId,
            $kind,
            $title,
            $body,
            array_filter([
                'route_name' => 'rtc_call',
                'route_args' => [
                    'call_id' => $session->id,
                    'call_key' => $session->call_key,
                    'peer_user_id' => $session->initiator_user_id,
                    'peer_name' => $session->initiator?->name ?: '好友',
                    'title' => $this->modeLabel((string) $session->mode),
                    'mode' => $session->mode,
                    ...$payload,
                ],
            ], static fn ($value) => $value !== null)
        );
    }

    private function notifyCounterpart(RtcSession $session, int $actorUserId, string $kind, string $title, string $body): void
    {
        $targetUserId = (int) $session->initiator_user_id === $actorUserId
            ? (int) $session->peer_user_id
            : (int) $session->initiator_user_id;

        $this->notifyPeer($targetUserId, $kind, $title, $body, $session, [
            'actor_user_id' => $actorUserId,
        ]);
    }

    private function displayNameForUser(?User $user): string
    {
        if (!$user) {
            return '未知用户';
        }

        $name = trim((string) ($user->nickname ?? ''));
        if ($name !== '') {
            return $name;
        }

        $name = trim((string) ($user->name ?? ''));
        if ($name !== '') {
            return $name;
        }

        return '用户 #' . (int) $user->id;
    }

    private function modeLabel(string $mode): string
    {
        return match ($mode) {
            'video' => '视频通话',
            default => '语音通话',
        };
    }
}
