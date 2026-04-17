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
        appVersionProvider: () async => '0.03.09',
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

    expect(service.calls.map((row) => row['path']).toList(), <String>[
      '/api/v1/telemetry/match-explanation-preview-opened',
      '/api/v1/telemetry/first-chat-entry',
      '/api/v1/telemetry/match-feedback-submitted',
    ]);
    expect(
      service.calls.map((row) {
        final body = row['body'] as Map<String, dynamic>;
        return body['event_name'];
      }).toList(),
      <String>[
        'match_explanation_preview_opened',
        'match_first_chat_entry',
        'match_feedback_submitted',
      ],
    );
  });
}

