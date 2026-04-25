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
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_permission_service.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/pages/rtc_permission_page.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

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

class FakeRtcPermissionService implements RtcPermissionService {
  FakeRtcPermissionService({required this.granted});

  bool granted;
  bool openSettingsCalled = false;

  @override
  Future<bool> ensureVoiceCallPermission() async => granted;

  @override
  Future<bool> hasVoiceCallPermission() async => granted;

  @override
  Future<bool> openSettings() async {
    openSettingsCalled = true;
    return true;
  }
}

Widget _wrap(Widget child, {required FakeRtcPermissionService service}) {
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
      rtcPermissionServiceProvider.overrideWithValue(service),
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
  testWidgets('RtcPermissionPage renders permission hints and actions', (
    tester,
  ) async {
    final service = FakeRtcPermissionService(granted: false);

    await tester.pumpWidget(
      _wrap(
        const RtcPermissionPage(title: '通话权限'),
        service: service,
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('通话权限'), findsWidgets);
    expect(find.text('麦克风权限'), findsOneWidget);
    expect(find.text('申请麦克风权限'), findsWidgets);
    expect(find.text('打开系统设置'), findsWidgets);
    expect(find.text('返回'), findsWidgets);
  });
}
