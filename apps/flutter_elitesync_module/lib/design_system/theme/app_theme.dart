import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync_module/design_system/theme/dark_theme.dart';
import 'package:flutter_elitesync_module/design_system/theme/light_theme.dart';

abstract final class AppTheme {
  static ThemeData light = buildLightTheme();
  static ThemeData dark = buildDarkTheme();

  static ThemeMode resolveThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }
}
