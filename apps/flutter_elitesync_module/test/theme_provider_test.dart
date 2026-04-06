import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/theme_provider.dart';

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
}

ProviderContainer _container({
  required AppEnv env,
  required FakeLocalStorageService storage,
}) {
  return ProviderContainer(
    overrides: [
      appEnvProvider.overrideWithValue(env),
      localStorageProvider.overrideWithValue(storage),
    ],
  );
}

void main() {
  test('dev defaults to dark and persists theme selection', () async {
    final storage = FakeLocalStorageService();
    final container = _container(
      env: const AppEnv(
        flavor: AppFlavor.dev,
        appName: 'EliteSync Dev',
        apiBaseUrl: 'http://101.133.161.203',
        useMockData: true,
      ),
      storage: storage,
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), AppThemeMode.dark);

    await container.read(themeModeProvider.notifier).setThemeMode(AppThemeMode.light);

    expect(container.read(themeModeProvider), AppThemeMode.light);
    expect(await storage.getString(CacheKeys.appThemeMode), AppThemeMode.light.name);
  });

  test('hydrates persisted theme mode on startup', () async {
    final storage = FakeLocalStorageService({
      CacheKeys.appThemeMode: AppThemeMode.light.name,
    });
    final container = _container(
      env: const AppEnv(
        flavor: AppFlavor.prod,
        appName: 'EliteSync',
        apiBaseUrl: 'http://101.133.161.203',
        useMockData: false,
      ),
      storage: storage,
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), AppThemeMode.system);

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(themeModeProvider), AppThemeMode.light);
  });
}
