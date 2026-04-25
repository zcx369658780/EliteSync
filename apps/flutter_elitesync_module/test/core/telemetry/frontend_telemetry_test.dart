import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.04.04',
      );

  final List<Map<String, Object?>> calls = <Map<String, Object?>>[];

  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    calls.add({'path': path, 'sourcePage': sourcePage, 'body': body});
    return const NetworkSuccess(<String, dynamic>{});
  }
}

void main() {
  test('frontend telemetry emits distinct routes for distinct actions', () {
    final service = FakeAppTelemetryService();
    final telemetry = FrontendTelemetry(telemetry: service);

    telemetry.questionnaireEntryOpened(sourcePage: 'questionnaire');
    telemetry.questionnaireSubmitted(
      sourcePage: 'questionnaire',
      questionnaireVersion: 'q_v2',
      bankVersion: 'qb_v1',
      attemptVersion: 'qa_v1',
    );
    telemetry.questionnaireResultViewed(sourcePage: 'questionnaire_result');
    telemetry.questionnaireHistoryOpened(sourcePage: 'questionnaire_history');
    telemetry.questionnaireRetestStarted(sourcePage: 'questionnaire_result');
    telemetry.homepagePersonalitySummaryOpened(sourcePage: 'home');
    telemetry.matchPersonalityHintOpened(sourcePage: 'match_result');
    telemetry.matchExplanationEntry(
      targetUserId: 12,
      sourcePage: 'match_result',
      matchId: 34,
    );
    telemetry.firstChatEntry(
      targetUserId: 12,
      sourcePage: 'match_result',
      matchId: 34,
    );
    telemetry.matchFeedbackSubmitted(
      targetUserId: 12,
      sourcePage: 'match_feedback',
      matchId: 34,
    );
    telemetry.chatImagePickerOpened(sourcePage: 'chat_room');
    telemetry.chatImageUploadStarted(sourcePage: 'chat_room');
    telemetry.chatImageUploadSucceeded(sourcePage: 'chat_room', assetId: 99);
    telemetry.chatImageUploadFailed(
      sourcePage: 'chat_room',
      errorCode: 'upload_failed',
    );
    telemetry.chatImageMessageSent(sourcePage: 'chat_room', attachmentCount: 1);
    telemetry.chatVideoPickerOpened(sourcePage: 'chat_room');
    telemetry.chatVideoUploadStarted(sourcePage: 'chat_room');
    telemetry.chatVideoUploadSucceeded(sourcePage: 'chat_room', assetId: 100);
    telemetry.chatVideoUploadFailed(
      sourcePage: 'chat_room',
      errorCode: 'upload_failed',
    );
    telemetry.chatVideoMessageSent(sourcePage: 'chat_room', attachmentCount: 1);
    telemetry.chatVideoPlaybackOpened(sourcePage: 'chat_room');
    telemetry.notificationCenterOpened(sourcePage: 'notification_center');
    telemetry.notificationItemOpened(
      sourcePage: 'notification_center',
      kind: 'message',
    );
    telemetry.notificationAllRead(
      sourcePage: 'notification_center',
      unreadCount: 3,
    );

    expect(service.calls, hasLength(24));
    expect(
      service.calls.map((row) => row['path']).whereType<String>().toSet(),
      <String>{
        '/api/v1/telemetry/events',
        '/api/v1/telemetry/match-explanation-preview-opened',
        '/api/v1/telemetry/first-chat-entry',
        '/api/v1/telemetry/match-feedback-submitted',
      },
    );
    expect(
      service.calls
          .map((row) {
            final body = row['body'] as Map<String, dynamic>;
            return body['event_name'];
          })
          .whereType<String>()
          .toSet(),
      <String>{
        'questionnaire_entry_opened',
        'questionnaire_submitted',
        'questionnaire_result_viewed',
        'questionnaire_history_opened',
        'questionnaire_retest_started',
        'homepage_personality_summary_opened',
        'match_personality_hint_opened',
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
        'notification_center_opened',
        'notification_item_opened',
        'notification_all_read',
        'match_explanation_preview_opened',
        'match_first_chat_entry',
        'match_feedback_submitted',
      },
    );
    expect(service.calls[1]['body'], isA<Map<String, dynamic>>());
  });
}
