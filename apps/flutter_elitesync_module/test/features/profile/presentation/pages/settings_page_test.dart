import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/settings_page.dart';
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

class FakeSecureStorageService extends SecureStorageService {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async {
    return _values[key];
  }

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}

Future<void> _pumpSettingsPage(
  WidgetTester tester, {
  required AppFlavor flavor,
  required String? phone,
}) async {
  final localStorage = FakeLocalStorageService();
  final secureStorage = FakeSecureStorageService();

  if (phone != null) {
    await secureStorage.write(CacheKeys.accessToken, 'test-token');
    await localStorage.setJson(CacheKeys.lastKnownProfile, {
      'id': 8,
      'phone': phone,
      'nickname': 'tester',
    });
  }

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(
          AppEnv(
            flavor: flavor,
            appName: 'EliteSync',
            apiBaseUrl: 'http://localhost',
            useMockData: true,
          ),
        ),
        localStorageProvider.overrideWithValue(localStorage),
        secureStorageProvider.overrideWithValue(secureStorage),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const SettingsPage(),
      ),
    ),
  );

  await tester.pumpAndSettle();
}

void main() {
  testWidgets('SettingsPage shows explanation control contract', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );

    await tester.scrollUntilVisible(
      find.text('解释与建议设置'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('解释与建议设置'), findsOneWidget);
    expect(find.text('关系解释提示'), findsOneWidget);
    expect(find.text('个人表达建议'), findsOneWidget);
    expect(find.text('聊天开场建议'), findsOneWidget);
    expect(find.textContaining('不会写入资料'), findsWidgets);
    expect(find.textContaining('不会改变星盘或匹配算法'), findsWidgets);
    expect(find.textContaining('不会自动发送消息'), findsWidgets);
    expect(find.textContaining('关闭后仍可使用主流程'), findsWidgets);
    expect(find.text('了解这些建议如何工作'), findsOneWidget);
    expect(find.text('账号与安全'), findsOneWidget);
    expect(find.text('修改密码'), findsOneWidget);
  });

  testWidgets('SettingsPage opens explanation control sheet', (tester) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );

    await tester.scrollUntilVisible(
      find.text('了解这些建议如何工作'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 140));
    await tester.pumpAndSettle();

    await tester.tap(find.text('了解这些建议如何工作'));
    await tester.pumpAndSettle();

    expect(find.text('这些建议如何工作'), findsOneWidget);
    expect(find.textContaining('不会读取私密聊天'), findsOneWidget);
    expect(find.textContaining('不会写入资料'), findsWidgets);
    expect(find.textContaining('不会自动发送消息'), findsWidgets);
    expect(find.textContaining('关闭后仍可使用匹配、个人资料和聊天主流程'), findsOneWidget);
  });

  testWidgets('SettingsPage opens appearance boundary sheet', (tester) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.dev,
      phone: '17094346566',
    );

    expect(find.text('个人空间外观'), findsOneWidget);

    await tester.tap(find.text('个人空间外观'));
    await tester.pumpAndSettle();

    expect(find.text('个人空间外观仍是预览层'), findsOneWidget);
    expect(find.text('知道了'), findsWidgets);
  });

  testWidgets('SettingsPage shows admin entries for configured admin phone', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '13772423130',
    );

    await tester.scrollUntilVisible(
      find.text('开发者'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('开发者'), findsOneWidget);
    expect(find.text('运营看板'), findsOneWidget);
    expect(find.text('运营后台'), findsOneWidget);
  });

  testWidgets('SettingsPage hides admin entries for non-admin prod user', (
    tester,
  ) async {
    await _pumpSettingsPage(
      tester,
      flavor: AppFlavor.prod,
      phone: '17094346566',
    );

    expect(find.text('开发者'), findsNothing);
    expect(find.text('运营看板'), findsNothing);
    expect(find.text('运营后台'), findsNothing);
  });
}
