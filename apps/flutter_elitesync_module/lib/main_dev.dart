import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

String _resolveApiBaseUrl() {
  final override = String.fromEnvironment('ELITESYNC_API_BASE_URL').trim();
  if (override.isNotEmpty) {
    return override.endsWith('/') ? override : '$override/';
  }
  final fileBootstrap = _readBootstrapFile();
  final fileOverride = fileBootstrap['elitesync_api_base_url']?.trim() ?? '';
  if (fileOverride.isNotEmpty) {
    return fileOverride.endsWith('/') ? fileOverride : '$fileOverride/';
  }
  return 'http://101.133.161.203/';
}

Map<String, String> _readBootstrapFile() {
  const bootstrapPath =
      '/data/data/com.elitesync.flutter_elitesync_module.host/files/elitesync_bootstrap.json';
  final file = File(bootstrapPath);
  if (!file.existsSync()) return const {};
  try {
    final decoded = jsonDecode(file.readAsStringSync());
    if (decoded is Map) {
      return decoded.map(
        (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
      );
    }
  } catch (_) {
    // Ignore malformed bootstrap file and fall back to environment defaults.
  }
  return const {};
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final fileBootstrap = _readBootstrapFile();
  final initialRoute =
      String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim().isNotEmpty
      ? String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim()
      : (fileBootstrap['elitesync_initial_route'] ?? '').trim();
  runEliteSyncApp(
    AppEnv(
      flavor: AppFlavor.dev,
      appName: 'EliteSync Dev',
      apiBaseUrl: _resolveApiBaseUrl(),
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: false,
      useMockHome: false,
      useMockMatch: false,
      useMockChat: false,
      useMockProfile: false,
      useMockAdmin: false,
      initialRoute: initialRoute.isEmpty ? null : initialRoute,
    ),
  );
}
