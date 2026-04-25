import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_result_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/providers/rtc_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
      : super(
          apiClient: ApiClient(
            dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
          ),
          appVersionProvider: () async => '0.04.06',
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

class FakeRtcRemoteDataSource extends RtcRemoteDataSource {
  FakeRtcRemoteDataSource(this._session)
      : super(
          apiClient: ApiClient(
            dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
          ),
        );

  RtcSessionEntity _session;

  @override
  Future<RtcSessionEntity> fetchCall(int callId) async => _session;

  @override
  Future<RtcSessionEntity> acceptCall(int callId) async => _session;

  @override
  Future<RtcSessionEntity> connectCall(int callId) async => _session;

  @override
  Future<RtcSessionEntity> rejectCall(int callId) async => _session;

  @override
  Future<RtcSessionEntity> endCall(int callId) async => _session;
}

Widget _wrap(Widget child, {required RtcRemoteDataSource rtc}) {
  final telemetry = FakeAppTelemetryService();
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync',
          apiBaseUrl: 'http://127.0.0.1',
          useMockData: true,
        ),
      ),
      frontendTelemetryProvider.overrideWithValue(
        FrontendTelemetry(telemetry: telemetry),
      ),
      rtcRemoteDataSourceProvider.overrideWithValue(rtc),
    ],
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: child,
    ),
  );
}

void main() {
  testWidgets('RtcCallResultPage renders terminal summary', (tester) async {
    final session = RtcSessionEntity.fromJson({
      'id': 3,
      'call_key': 'call-3',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'rejected',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': true,
      'accepted_by_user_id': null,
      'ended_by_user_id': 2,
      'failure_code': 'rejected',
      'failure_message': '通话已被拒绝',
      'ringing_at': '2026-04-21T12:00:00Z',
      'accepted_at': null,
      'started_at': null,
      'ended_at': '2026-04-21T12:00:03Z',
      'expires_at': '2026-04-21T12:02:00Z',
      'created_at': '2026-04-21T12:00:00Z',
      'updated_at': '2026-04-21T12:00:00Z',
      'latest_event_name': 'rejected',
      'events': [
        {
          'id': 1,
          'event_name': 'created',
          'user_id': 1,
          'payload': {'mode': 'voice'},
          'created_at': '2026-04-21T12:00:00Z',
        },
        {
          'id': 2,
          'event_name': 'rejected',
          'user_id': 2,
          'payload': const <String, dynamic>{},
          'created_at': '2026-04-21T12:00:03Z',
        },
      ],
      'is_active': false,
      'is_terminal': true,
    });
    final rtc = FakeRtcRemoteDataSource(session);

    await tester.pumpWidget(
      _wrap(
        const RtcCallResultPage(callId: 3, title: '通话结果'),
        rtc: rtc,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('通话结果'), findsWidgets);
    expect(find.text('Callee'), findsOneWidget);
    expect(find.text('已拒绝'), findsOneWidget);
    expect(find.text('返回上一页'), findsWidgets);
  });
}
