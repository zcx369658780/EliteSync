import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final debugAccessTokenB64 = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN_B64',
  ).trim();
  final debugAccessTokenRaw = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN',
  ).trim();
  final debugAccessToken = debugAccessTokenB64.isNotEmpty
      ? utf8.decode(base64Decode(debugAccessTokenB64))
      : debugAccessTokenRaw;
  final debugRefreshToken = String.fromEnvironment(
    'ELITESYNC_DEBUG_REFRESH_TOKEN',
  ).trim();
  final debugAutoLoginPhone = String.fromEnvironment(
    'ELITESYNC_DEBUG_AUTO_LOGIN_PHONE',
  ).trim();
  final debugAutoLoginPassword = String.fromEnvironment(
    'ELITESYNC_DEBUG_AUTO_LOGIN_PASSWORD',
  ).trim();
  // Dev-only diagnostic: confirms whether compile-time injection reached the app.
  // Remove once the /messages real-chain check is finished.
  // ignore: avoid_print
  print(
    'DEV_BOOTSTRAP token=${debugAccessToken.isNotEmpty} route=${String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim()}',
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
      apiBaseUrl: 'http://101.133.161.203',
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: true,
      useMockHome: false,
      useMockMatch: true,
      useMockChat: const bool.fromEnvironment('ELITESYNC_CHAT_MOCK'),
      useMockProfile: false,
      useMockAdmin: const bool.fromEnvironment('ELITESYNC_ADMIN_MOCK'),
      initialRoute:
          String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim().isEmpty
          ? null
          : String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim(),
      debugAccessToken: debugAccessToken,
      debugRefreshToken: debugRefreshToken,
      debugAutoLoginPhone: debugAutoLoginPhone,
      debugAutoLoginPassword: debugAutoLoginPassword,
    ),
  );
}
