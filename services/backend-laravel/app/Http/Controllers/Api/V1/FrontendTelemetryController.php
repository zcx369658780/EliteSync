<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\EventLogger;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class FrontendTelemetryController extends Controller
{
    public function store(Request $request, EventLogger $events): JsonResponse
    {
        $data = $request->validate([
            'event_name' => [
                'required',
                'string',
                'max:64',
                Rule::in([
                    'match_explanation_view',
                    'first_chat_entry',
                    'match_feedback_submit',
                    'match_explanation_preview_opened',
                    'match_first_chat_entry',
                    'match_feedback_submitted',
                    'chat_image_picker_opened',
                    'chat_image_upload_started',
                    'chat_image_upload_succeeded',
                    'chat_image_upload_failed',
                    'chat_image_message_sent',
                    'chat_video_picker_opened',
                    'chat_video_upload_started',
                    'chat_video_upload_succeeded',
                    'chat_video_upload_failed',
                    'chat_video_message_sent',
                    'chat_video_playback_opened',
                    'rtc_call_entry_opened',
                    'rtc_call_status_changed',
                ]),
            ],
            'target_user_id' => ['nullable', 'integer', 'min:1'],
            'match_id' => ['nullable', 'integer', 'min:1'],
            'source_page' => ['nullable', 'string', 'max:64'],
            'payload' => ['nullable', 'array'],
        ]);

        $sourcePage = trim((string) ($data['source_page'] ?? $request->header('X-Source-Page', '')));
        $appVersion = trim((string) $request->header('X-App-Version', ''));
        $payload = $data['payload'] ?? [];
        if (!is_array($payload)) {
            $payload = [];
        }
        $payload = array_filter([
            'source_page' => $sourcePage !== '' ? $sourcePage : null,
            'app_version' => $appVersion !== '' ? $appVersion : null,
            'client_event' => $data['event_name'],
            'client_payload' => $payload,
        ], static fn ($value) => $value !== null && $value !== []);

        $events->log(
            eventName: $data['event_name'],
            actorUserId: $request->user()?->id,
            targetUserId: isset($data['target_user_id']) ? (int) $data['target_user_id'] : null,
            matchId: isset($data['match_id']) ? (int) $data['match_id'] : null,
            payload: $payload,
        );

        return response()->json([
            'ok' => true,
        ]);
    }
}
