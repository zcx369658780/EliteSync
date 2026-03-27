import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/app/router/app_router.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';
import 'package:flutter_elitesync/shared/providers/theme_provider.dart';

class EliteSyncApp extends ConsumerWidget {
  const EliteSyncApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: env.appName,
      debugShowCheckedModeBanner: env.isDev,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: AppTheme.resolveThemeMode(themeMode),
      routerConfig: router,
    );
  }
}
