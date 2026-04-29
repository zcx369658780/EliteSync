import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';

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

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: Material(
        child: child,
      ),
    ),
  );
}

void main() {
  testWidgets('notification center renders notifications and unread count', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 1,
                kind: 'message',
                title: 'test1 发来一条消息',
                body: '图片消息',
                payload: const {
                  'route_name': 'chat_room',
                  'route_args': {
                    'conversation_id': 'chat-1',
                    'title': 'test1',
                  },
                },
                routeName: 'chat_room',
                routeArgs: const {
                  'conversation_id': 'chat-1',
                  'title': 'test1',
                },
                isRead: false,
                createdAt: '2026-04-21T12:00:00Z',
              ),
            ],
          ),
          notificationUnreadCountProvider.overrideWith((ref) async => 1),
        ],
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('通知中心'), findsOneWidget);
    expect(find.text('站内提醒'), findsWidgets);
    expect(find.textContaining('未读 1 条'), findsOneWidget);
    expect(find.text('test1 发来一条消息'), findsOneWidget);
    expect(find.text('图片消息'), findsOneWidget);
    expect(find.text('新消息'), findsWidgets);
    expect(find.text('message'), findsNothing);
    expect(
      telemetry.calls.any(
        (row) =>
            row['path'] == '/api/v1/telemetry/events' &&
            (row['body'] as Map<String, dynamic>)['event_name'] ==
                'notification_center_opened',
      ),
      isTrue,
    );
  });
}
