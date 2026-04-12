import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
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
  final debugAccessTokenB64 = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN_B64',
  ).trim();
  final debugAccessTokenRaw = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN',
  ).trim();
  final debugAccessToken = debugAccessTokenB64.isNotEmpty
      ? utf8.decode(base64Decode(debugAccessTokenB64))
      : (debugAccessTokenRaw.isNotEmpty
          ? debugAccessTokenRaw
          : (fileBootstrap['elitesync_debug_access_token'] ?? '').trim());
  final debugRefreshToken = String.fromEnvironment(
    'ELITESYNC_DEBUG_REFRESH_TOKEN',
  ).trim().isNotEmpty
      ? String.fromEnvironment('ELITESYNC_DEBUG_REFRESH_TOKEN').trim()
      : (fileBootstrap['elitesync_debug_refresh_token'] ?? '').trim();
  final debugAutoLoginPhone = String.fromEnvironment(
    'ELITESYNC_DEBUG_AUTO_LOGIN_PHONE',
  ).trim().isNotEmpty
      ? String.fromEnvironment('ELITESYNC_DEBUG_AUTO_LOGIN_PHONE').trim()
      : (fileBootstrap['elitesync_debug_auto_login_phone'] ?? '').trim();
  final debugAutoLoginPassword = String.fromEnvironment(
    'ELITESYNC_DEBUG_AUTO_LOGIN_PASSWORD',
  ).trim().isNotEmpty
      ? String.fromEnvironment('ELITESYNC_DEBUG_AUTO_LOGIN_PASSWORD').trim()
      : (fileBootstrap['elitesync_debug_auto_login_password'] ?? '').trim();
  final initialRoute = String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim().isNotEmpty
      ? String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim()
      : (fileBootstrap['elitesync_initial_route'] ?? '').trim();
  // Dev-only diagnostic: confirms whether compile-time injection reached the app.
  // Remove once the /messages real-chain check is finished.
  // ignore: avoid_print
  print(
    'DEV_BOOTSTRAP token=${debugAccessToken.isNotEmpty} route=$initialRoute',
  );
  if (debugAccessToken.isNotEmpty) {
    final secure = SecureStorageService();
    await secure.write(CacheKeys.accessToken, debugAccessToken);
    if (debugRefreshToken.isNotEmpty) {
      await secure.write(CacheKeys.refreshToken, debugRefreshToken);
    }
  }
  runEliteSyncApp(
    AppEnv(
      flavor: AppFlavor.dev,
      appName: 'EliteSync Dev',
      apiBaseUrl: _resolveApiBaseUrl(),
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: true,
      useMockHome: false,
      useMockMatch: true,
      useMockChat: const bool.fromEnvironment('ELITESYNC_CHAT_MOCK'),
      useMockProfile: false,
      useMockAdmin: const bool.fromEnvironment('ELITESYNC_ADMIN_MOCK'),
      initialRoute: initialRoute.isEmpty ? null : initialRoute,
      debugAccessToken: debugAccessToken,
      debugRefreshToken: debugRefreshToken,
      debugAutoLoginPhone: debugAutoLoginPhone,
      debugAutoLoginPassword: debugAutoLoginPassword,
    ),
  );
}
