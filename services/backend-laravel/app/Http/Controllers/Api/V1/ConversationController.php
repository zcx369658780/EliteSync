<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\ConversationDomainService;
use Illuminate\Support\Facades\Log;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ConversationController extends Controller
{
    public function index(Request $request, ConversationDomainService $service): JsonResponse
    {
        $items = $service->listForUser($request->user());

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'items' => $items->values(),
            'total' => $items->count(),
            'note' => $items->isEmpty() ? '4.0A conversation domain skeleton only' : null,
        ]);
    }

    public function store(Request $request, ConversationDomainService $service): JsonResponse
    {
        $data = $request->validate([
            'peer_user_id' => ['required', 'integer', 'exists:users,id'],
            'title' => ['nullable', 'string', 'max:120'],
        ]);

        $conversation = $service->ensureDirectConversation(
            (int) $request->user()->id,
            (int) $data['peer_user_id'],
            $data['title'] ?? null
        );

        Log::info('conversation_created', [
            'conversation_id' => $conversation->id,
            'room_key' => $conversation->room_key,
            'actor_user_id' => (int) $request->user()->id,
            'peer_user_id' => (int) $data['peer_user_id'],
        ]);

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'conversation' => $service->summarizeConversation($conversation, (int) $request->user()->id),
        ]);
    }

    public function show(Request $request, int $conversationId, ConversationDomainService $service): JsonResponse
    {
        $conversation = $service->findDirectConversation((int) $request->user()->id, $conversationId);
        if (!$conversation) {
            $fallback = collect($service->fallbackFromMatches($request->user()))
                ->firstWhere('peer_user_id', $conversationId);
            if ($fallback) {
                return response()->json([
                    'ok' => true,
                    'domain' => 'conversation',
                    'conversation' => $fallback,
                ]);
            }

            return response()->json(['message' => 'conversation not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'domain' => 'conversation',
            'conversation' => $service->summarizeConversation($conversation, (int) $request->user()->id),
        ]);
    }
}
