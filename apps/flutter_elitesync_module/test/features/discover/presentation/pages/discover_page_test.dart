import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/pages/discover_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class FakeLocalStorageService extends LocalStorageService {
  final Map<String, Object?> _values = <String, Object?>{};

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
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
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }

  @override
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }
}

void main() {
  testWidgets('DiscoverPage opens local action sheet from card long press', (
    tester,
  ) async {
    final localStorage = FakeLocalStorageService();
    final remote = HomeRemoteDataSource(
      apiClient: ApiClient(dio: Dio()),
      useMock: true,
      localStorage: localStorage,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync',
              apiBaseUrl: 'http://localhost',
              useMockData: true,
              useMockHome: true,
            ),
          ),
          localStorageProvider.overrideWithValue(localStorage),
          homeRemoteDataSourceProvider.overrideWithValue(remote),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.light,
          home: const DiscoverPage(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final actionableCards = find.byWidgetPredicate(
      (widget) => widget is InkWell && widget.onLongPress != null,
    );
    expect(actionableCards, findsWidgets);

    await tester.longPress(actionableCards.first);
    await tester.pumpAndSettle();

    expect(find.text('推荐理由'), findsOneWidget);
    expect(find.text('继续看详情'), findsOneWidget);
    expect(find.text('稍后再看'), findsOneWidget);
    expect(find.text('继续搜标签'), findsOneWidget);
    expect(find.text('记住偏好'), findsOneWidget);
  });
}
