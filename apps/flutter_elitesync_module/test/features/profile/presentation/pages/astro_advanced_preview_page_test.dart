import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_advanced_preview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  FakeLocalStorageService([Map<String, Object?>? initialValues]) {
    _values.addAll(initialValues ?? const {});
  }

  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

Widget _wrap(Widget child, {Iterable<dynamic> overrides = const []}) {
  return ProviderScope(
    overrides: [
      appEnvProvider.overrideWithValue(
        const AppEnv(
          flavor: AppFlavor.dev,
          appName: 'EliteSync Dev',
          apiBaseUrl: 'http://101.133.161.203',
          useMockData: true,
          useMockHome: true,
          useMockMatch: true,
          useMockChat: true,
        ),
      ),
      localStorageProvider.overrideWithValue(FakeLocalStorageService()),
      ...overrides,
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
  testWidgets('advanced preview page renders detail sections', (tester) async {
    final bundle = AstroAdvancedPreviewBundle(
      routeMode: AstroChartRouteMode.modern,
      timing: buildAstroTimingFrameworkBundle(
        const {'name': '华严魂', 'birthday': '1994-04-17', 'birth_time': '09:30'},
        AstroChartRouteMode.modern,
        referenceNow: DateTime(2026, 4, 17, 10, 30),
      ),
      requests: const AstroAdvancedPreviewRequests(
        pair: {'route_mode': 'modern'},
        comparison: {'route_mode': 'modern'},
        transit: {'route_mode': 'modern'},
        returnChart: {'route_mode': 'modern'},
      ),
      pair: const AstroAdvancedPreviewItem(
        title: '合盘预览',
        summary: '双人关系摘要',
        routeMode: 'modern',
        generatedAt: '2026-04-12 15:26',
        primaryName: '华严魂',
        secondaryName: '晨雾',
        primaryPointCount: 10,
        secondaryPointCount: 10,
        aspectCount: 4,
        chartKind: 'synastry',
        advancedMode: 'pair',
        pairMode: 'synastry',
        relationshipScoreDescription: '78 / 100',
        relationshipScoreValue: 78,
      ),
      comparison: const AstroAdvancedPreviewItem(
        title: '对比盘预览',
        summary: '差异对照摘要',
        routeMode: 'modern',
        generatedAt: '2026-04-12 15:26',
        primaryName: '华严魂',
        secondaryName: '晨雾',
        primaryPointCount: 10,
        secondaryPointCount: 11,
        aspectCount: 5,
        chartKind: 'comparison',
        advancedMode: 'pair',
        pairMode: 'comparison',
        relationshipScoreDescription: '对照评分弱化',
        relationshipScoreValue: 61,
      ),
      transit: const AstroAdvancedPreviewItem(
        title: '行运预览',
        summary: '时间窗口摘要',
        routeMode: 'modern',
        generatedAt: '2026-04-12 15:26',
        primaryName: '华严魂',
        secondaryName: '行运档',
        primaryPointCount: 10,
        secondaryPointCount: 10,
        aspectCount: 6,
        chartKind: 'transit',
        advancedMode: 'transit',
      ),
      returnChart: const AstroAdvancedPreviewItem(
        title: '返照预览',
        summary: '返照年摘要',
        routeMode: 'modern',
        generatedAt: '2026-04-12 15:26',
        primaryName: '华严魂',
        secondaryName: '返照档',
        primaryPointCount: 10,
        secondaryPointCount: 10,
        aspectCount: 5,
        chartKind: 'return',
        advancedMode: 'return',
        returnType: 'Lunar',
        returnYear: 2026,
      ),
    );

    await tester.pumpWidget(
      _wrap(
        const AstroAdvancedPreviewPage(),
        overrides: [
          astroAdvancedPreviewProvider.overrideWith((ref) async => bundle),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('高级时法'), findsWidgets);
    expect(find.text('高级能力口径'), findsOneWidget);
    expect(find.text('高级时法框架'), findsOneWidget);
    expect(find.text('细粒度解释层'), findsOneWidget);
    expect(find.text('路线能力复核'), findsOneWidget);
    expect(find.text('高级样例矩阵'), findsOneWidget);
    expect(find.text('预览日志'), findsOneWidget);
    expect(find.text('返回设置中心'), findsOneWidget);
    expect(find.text('合盘预览'), findsWidgets);
    expect(find.text('对比盘预览'), findsWidgets);
    expect(find.text('行运预览'), findsWidgets);
    expect(find.text('返照预览'), findsWidgets);
  });
}
