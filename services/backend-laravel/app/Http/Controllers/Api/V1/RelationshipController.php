<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\UserRelationshipEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class RelationshipController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $user = $request->user();
        $items = UserRelationshipEvent::query()
            ->where(function ($query) use ($user) {
                $query->where('actor_user_id', $user->id)->orWhere('subject_user_id', $user->id);
            })
            ->orderByDesc('id')
            ->limit(30)
            ->get()
            ->map(function (UserRelationshipEvent $event) use ($user) {
                return [
                    'id' => $event->id,
                    'event_type' => $event->event_type,
                    'status' => $event->status,
                    'actor_user_id' => $event->actor_user_id,
                    'subject_user_id' => $event->subject_user_id,
                    'is_actor' => (int) $event->actor_user_id === (int) $user->id,
                    'happened_at' => optional($event->happened_at)->toIso8601String(),
                ];
            });

        return response()->json([
            'ok' => true,
            'items' => $items,
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $data = $request->validate([
            'subject_user_id' => ['required', 'integer', 'exists:users,id'],
            'event_type' => ['required', 'string', 'max:32'],
            'status' => ['nullable', 'string', 'max:24'],
            'metadata' => ['nullable', 'array'],
        ]);

        $event = UserRelationshipEvent::query()->create([
            'actor_user_id' => $request->user()->id,
            'subject_user_id' => $data['subject_user_id'],
            'event_type' => $data['event_type'],
            'status' => $data['status'] ?? 'recorded',
            'metadata' => $data['metadata'] ?? null,
            'happened_at' => now(),
        ]);

        Log::info('relationship_event_recorded', [
            'event_id' => (int) $event->id,
            'actor_user_id' => (int) $event->actor_user_id,
            'subject_user_id' => (int) $event->subject_user_id,
            'event_type' => (string) $event->event_type,
            'status' => (string) $event->status,
        ]);

        return response()->json([
            'ok' => true,
            'event' => $event,
        ]);
    }
}
