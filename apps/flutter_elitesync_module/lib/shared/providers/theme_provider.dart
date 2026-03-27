import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class ThemeModeNotifier extends Notifier<AppThemeMode> {
  bool _hydrated = false;

  @override
  AppThemeMode build() {
    final env = ref.read(appEnvProvider);
    final defaultMode = env.isProd ? AppThemeMode.system : AppThemeMode.dark;

    if (!_hydrated) {
      _hydrated = true;
      unawaited(_hydrate(defaultMode));
    }

    return defaultMode;
  }

  Future<void> _hydrate(AppThemeMode fallback) async {
    final storage = ref.read(localStorageProvider);
    final raw = await storage.getString(CacheKeys.appThemeMode);
    if (raw == null || raw.isEmpty) return;

    AppThemeMode? parsed;
    for (final m in AppThemeMode.values) {
      if (m.name == raw) {
        parsed = m;
        break;
      }
    }
    state = parsed ?? fallback;
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await ref
        .read(localStorageProvider)
        .setString(CacheKeys.appThemeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, AppThemeMode>(
  ThemeModeNotifier.new,
);
