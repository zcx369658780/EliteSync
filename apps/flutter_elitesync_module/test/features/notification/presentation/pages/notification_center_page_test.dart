import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/core/telemetry/frontend_telemetry.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/pages/notification_center_page.dart';
import 'package:flutter_elitesync_module/features/notification/presentation/providers/notification_provider.dart';

class FakeAppTelemetryService extends AppTelemetryService {
  FakeAppTelemetryService()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        appVersionProvider: () async => '0.04.09',
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

class FakeNotificationRemoteDataSource extends NotificationRemoteDataSource {
  FakeNotificationRemoteDataSource()
    : super(
        apiClient: ApiClient(
          dio: Dio(BaseOptions(baseUrl: 'http://127.0.0.1')),
        ),
        useMock: false,
      );

  final List<int> markedReadIds = <int>[];

  @override
  Future<void> markRead(int notificationId) async {
    markedReadIds.add(notificationId);
  }
}

Widget _wrap(Widget child, {List<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: overrides.cast(),
    child: MaterialApp(
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      home: Scaffold(body: Material(child: child)),
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
                  'route_args': {'conversation_id': 'chat-1', 'title': 'test1'},
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
    expect(find.text('消息回流'), findsOneWidget);
    expect(find.text('继续回复'), findsOneWidget);
    expect(find.text('稍后处理'), findsOneWidget);
    expect(find.text('标记已读'), findsOneWidget);
    expect(find.text('将回到对应聊天页。'), findsOneWidget);
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

  testWidgets(
    'primary action marks unread notification when route is missing',
    (tester) async {
      final telemetry = FakeAppTelemetryService();
      final notifications = FakeNotificationRemoteDataSource();

      await tester.pumpWidget(
        _wrap(
          const NotificationCenterPage(),
          overrides: [
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 2,
                  kind: 'system',
                  title: '资料完整度提醒',
                  body: '可以稍后处理',
                  payload: const {},
                  routeName: '',
                  routeArgs: const {},
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

      expect(find.text('低噪声提醒'), findsOneWidget);
      expect(find.text('仅标记已读'), findsOneWidget);

      await tester.tap(find.widgetWithText(OutlinedButton, '仅标记已读'));
      await tester.pumpAndSettle();

      expect(notifications.markedReadIds, <int>[2]);
    },
  );

  testWidgets('known kind with missing route still uses mark read action', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 4,
                kind: 'message',
                title: '消息提醒缺少跳转目标',
                body: '需要保留为低噪声处理',
                payload: const {},
                routeName: '',
                routeArgs: const {},
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

    expect(find.text('消息回流'), findsOneWidget);
    expect(find.text('仅标记已读'), findsOneWidget);
    expect(find.text('继续回复'), findsNothing);

    await tester.tap(find.widgetWithText(OutlinedButton, '仅标记已读'));
    await tester.pumpAndSettle();

    expect(notifications.markedReadIds, <int>[4]);
  });

  testWidgets('unsupported route does not mark unread notification as read', (
    tester,
  ) async {
    final telemetry = FakeAppTelemetryService();
    final notifications = FakeNotificationRemoteDataSource();

    await tester.pumpWidget(
      _wrap(
        const NotificationCenterPage(),
        overrides: [
          frontendTelemetryProvider.overrideWithValue(
            FrontendTelemetry(telemetry: telemetry),
          ),
          notificationRemoteDataSourceProvider.overrideWithValue(notifications),
          notificationListProvider.overrideWith(
            (ref) async => [
              NotificationItemEntity(
                id: 3,
                kind: 'system',
                title: '未知跳转提醒',
                body: '暂不支持打开',
                payload: const {
                  'route_name': 'legacy_unknown',
                  'route_args': <String, Object?>{},
                },
                routeName: 'legacy_unknown',
                routeArgs: const {},
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

    expect(find.text('暂不支持该跳转目标。'), findsOneWidget);
    expect(find.text('打开'), findsOneWidget);

    await tester.tap(find.widgetWithText(OutlinedButton, '打开'));
    await tester.pumpAndSettle();

    expect(notifications.markedReadIds, isEmpty);
  });

  testWidgets(
    'card tap on unsupported route does not mark notification as read',
    (tester) async {
      final telemetry = FakeAppTelemetryService();
      final notifications = FakeNotificationRemoteDataSource();

      await tester.pumpWidget(
        _wrap(
          const NotificationCenterPage(),
          overrides: [
            frontendTelemetryProvider.overrideWithValue(
              FrontendTelemetry(telemetry: telemetry),
            ),
            notificationRemoteDataSourceProvider.overrideWithValue(
              notifications,
            ),
            notificationListProvider.overrideWith(
              (ref) async => [
                NotificationItemEntity(
                  id: 5,
                  kind: 'system',
                  title: '未知跳转卡片',
                  body: '点击卡片也不应标记已读',
                  payload: const {
                    'route_name': 'legacy_unknown',
                    'route_args': <String, Object?>{},
                  },
                  routeName: 'legacy_unknown',
                  routeArgs: const {},
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

      await tester.tap(find.text('未知跳转卡片'));
      await tester.pumpAndSettle();

      expect(notifications.markedReadIds, isEmpty);
    },
  );
}
