<?php

namespace App\Services;

use App\Models\AppEvent;

class EventLogger
{
    public function log(
        string $eventName,
        ?int $actorUserId = null,
        ?int $targetUserId = null,
        ?int $matchId = null,
        array $payload = []
    ): void {
        AppEvent::create([
            'event_name' => $eventName,
            'actor_user_id' => $actorUserId,
            'target_user_id' => $targetUserId,
            'match_id' => $matchId,
            'payload' => $payload,
        ]);
    }
}

