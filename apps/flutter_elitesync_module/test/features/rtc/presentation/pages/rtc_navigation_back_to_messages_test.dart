import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_call_result_page.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_incoming_call_page.dart';
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

  @override
  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
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

  final RtcSessionEntity _session;

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

Widget _wrap({
  required RtcRemoteDataSource rtc,
  required String initialLocation,
}) {
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
        FrontendTelemetry(telemetry: FakeAppTelemetryService()),
      ),
      rtcRemoteDataSourceProvider.overrideWithValue(rtc),
    ],
    child: MaterialApp.router(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: AppRouteNames.messages,
            builder: (context, state) =>
                const Scaffold(body: Text('messages-page')),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCall}/:callId',
            builder: (context, state) => const RtcCallPage(
              callId: 1,
              title: '语音通话',
              autoConnect: false,
            ),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcIncomingCall}/:callId',
            builder: (context, state) => const RtcIncomingCallPage(
              callId: 2,
              title: '来电',
              autoAccept: false,
            ),
          ),
          GoRoute(
            path: '${AppRouteNames.rtcCallResult}/:callId',
            builder: (context, state) =>
                const RtcCallResultPage(callId: 3, title: '通话结果'),
          ),
        ],
      ),
    ),
  );
}

void main() {
  testWidgets('RtcCallResultPage back button returns to messages', (
    tester,
  ) async {
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
      'events': const [],
      'is_active': false,
      'is_terminal': true,
    });

    await tester.pumpWidget(
      _wrap(
        rtc: FakeRtcRemoteDataSource(session),
        initialLocation: '/rtc/result/3',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('返回上一页'));
    await tester.pumpAndSettle();

    expect(find.text('messages-page'), findsOneWidget);
  });

  testWidgets('RtcCallPage back button returns to messages', (tester) async {
    final session = RtcSessionEntity.fromJson({
      'id': 1,
      'call_key': 'call-1',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'ended',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': true,
      'accepted_by_user_id': 2,
      'ended_by_user_id': 2,
      'failure_code': null,
      'failure_message': null,
      'ringing_at': '2026-04-21T12:00:00Z',
      'accepted_at': '2026-04-21T12:00:01Z',
      'started_at': '2026-04-21T12:00:02Z',
      'ended_at': '2026-04-21T12:00:10Z',
      'expires_at': '2026-04-21T12:02:00Z',
      'created_at': '2026-04-21T12:00:00Z',
      'updated_at': '2026-04-21T12:00:00Z',
      'latest_event_name': 'ended',
      'events': const [],
      'is_active': false,
      'is_terminal': true,
    });

    await tester.pumpWidget(
      _wrap(
        rtc: FakeRtcRemoteDataSource(session),
        initialLocation: '/rtc/call/1',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('返回会话'));
    await tester.pumpAndSettle();

    expect(find.text('messages-page'), findsOneWidget);
  });

  testWidgets('RtcIncomingCallPage back button returns to messages', (
    tester,
  ) async {
    final session = RtcSessionEntity.fromJson({
      'id': 2,
      'call_key': 'call-2',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'ringing',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Caller',
      'peer_name': 'Callee',
      'is_initiator': false,
      'accepted_by_user_id': null,
      'ended_by_user_id': null,
      'failure_code': null,
      'failure_message': null,
      'ringing_at': '2026-04-21T12:00:00Z',
      'accepted_at': null,
      'started_at': null,
      'ended_at': null,
      'expires_at': '2026-04-21T12:02:00Z',
      'created_at': '2026-04-21T12:00:00Z',
      'updated_at': '2026-04-21T12:00:00Z',
      'latest_event_name': 'created',
      'events': const [],
      'is_active': true,
      'is_terminal': false,
    });

    await tester.pumpWidget(
      _wrap(
        rtc: FakeRtcRemoteDataSource(session),
        initialLocation: '/rtc/incoming/2',
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('返回'));
    await tester.pumpAndSettle();

    expect(find.text('messages-page'), findsOneWidget);
  });
}
