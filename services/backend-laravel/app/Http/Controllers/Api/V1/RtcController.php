<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\RtcSession;
use App\Services\LiveKitTokenService;
use App\Services\RtcSessionService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class RtcController extends Controller
{
    public function index(Request $request, RtcSessionService $service): JsonResponse
    {
        $items = $service->listForUser((int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'items' => $items->map(fn (RtcSession $session) => $service->summarizeSession($session, (int) $request->user()->id))->values(),
            'total' => $items->count(),
        ]);
    }

    public function store(Request $request, RtcSessionService $service): JsonResponse
    {
        $data = $request->validate([
            'peer_user_id' => ['required', 'integer', 'exists:users,id'],
            'mode' => ['nullable', 'string', 'in:voice,video'],
        ]);

        $session = $service->createCall(
            (int) $request->user()->id,
            (int) $data['peer_user_id'],
            (string) ($data['mode'] ?? 'voice')
        );

        Log::info('rtc_call_created', [
            'rtc_session_id' => (int) $session->id,
            'call_key' => (string) $session->call_key,
            'actor_user_id' => (int) $request->user()->id,
            'peer_user_id' => (int) $data['peer_user_id'],
            'mode' => (string) $session->mode,
            'status' => (string) $session->status,
        ]);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function show(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function accept(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        $session = $service->acceptCall($session, (int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function connect(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        $session = $service->connectCall($session, (int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function heartbeat(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        Log::info('rtc_call_heartbeat', [
            'rtc_session_id' => (int) $session->id,
            'call_id' => (int) $callId,
            'user_id' => (int) $request->user()->id,
            'room_name' => (string) $session->room_key,
            'mode' => (string) $session->mode,
        ]);

        $session = $service->heartbeatCall($session, (int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function reject(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        $session = $service->rejectCall($session, (int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function end(Request $request, int $callId, RtcSessionService $service): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        $session = $service->endCall($session, (int) $request->user()->id);

        return response()->json([
            'ok' => true,
            'session' => $service->summarizeSession($session, (int) $request->user()->id),
        ]);
    }

    public function livekit(Request $request, int $callId, RtcSessionService $service, LiveKitTokenService $tokenService): JsonResponse
    {
        $session = $service->findForUser((int) $request->user()->id, $callId);
        if (!$session) {
            return response()->json(['message' => 'call not found'], 404);
        }

        Log::info('rtc_livekit_join_info_requested', [
            'rtc_session_id' => (int) $session->id,
            'call_id' => (int) $callId,
            'user_id' => (int) $request->user()->id,
            'room_name' => (string) $session->room_key,
            'mode' => (string) $session->mode,
        ]);

        $payload = $tokenService->issueJoinInfo($session, $request->user());

        return response()->json([
            'ok' => true,
            'livekit' => $payload,
        ]);
    }
}
