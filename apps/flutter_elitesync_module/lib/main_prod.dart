import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

Future<Map<String, String>> _readHostBootstrap() async {
  try {
    const channel = MethodChannel('elitesync/bootstrap');
    final payload = await channel.invokeMapMethod<dynamic, dynamic>('getBootstrap');
    if (payload == null) return const {};
    return payload.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  } catch (_) {
    return const {};
  }
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hostBootstrap = await _readHostBootstrap();
  final debugAccessTokenB64 = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN_B64',
  ).trim();
  final debugAccessTokenRaw = String.fromEnvironment(
    'ELITESYNC_DEBUG_ACCESS_TOKEN',
  ).trim();
  final debugAccessTokenFromDefine = debugAccessTokenB64.isNotEmpty
      ? utf8.decode(base64Decode(debugAccessTokenB64))
      : debugAccessTokenRaw;
  final debugAccessToken = _firstNonEmpty([
    debugAccessTokenFromDefine,
    hostBootstrap['debugAccessToken'] ?? '',
  ]);
  final debugRefreshToken = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_DEBUG_REFRESH_TOKEN'),
    hostBootstrap['debugRefreshToken'] ?? '',
  ]);
  final debugAutoLoginPhone = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_DEBUG_AUTO_LOGIN_PHONE'),
    hostBootstrap['debugAutoLoginPhone'] ?? '',
  ]);
  final debugAutoLoginPassword = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_DEBUG_AUTO_LOGIN_PASSWORD'),
    hostBootstrap['debugAutoLoginPassword'] ?? '',
  ]);
  final chatMockFromHost = (hostBootstrap['chatMock'] ?? '').toLowerCase() == 'true';
  final chatMockFromDefine = const bool.fromEnvironment('ELITESYNC_CHAT_MOCK');
  final adminMockFromHost = (hostBootstrap['adminMock'] ?? '').toLowerCase() == 'true';
  final adminMockFromDefine = const bool.fromEnvironment('ELITESYNC_ADMIN_MOCK');
  final initialRoute = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_INITIAL_ROUTE'),
    hostBootstrap['initialRoute'] ?? '',
  ]);
  final hasDebugBootstrap =
      debugAccessToken.isNotEmpty ||
      debugRefreshToken.isNotEmpty ||
      debugAutoLoginPhone.isNotEmpty ||
      debugAutoLoginPassword.isNotEmpty ||
      initialRoute.isNotEmpty;

  // ignore: avoid_print
  print(
    'MAIN_PROD_BOOTSTRAP token=${debugAccessToken.isNotEmpty} refresh=${debugRefreshToken.isNotEmpty} autoLogin=${debugAutoLoginPhone.isNotEmpty && debugAutoLoginPassword.isNotEmpty} initialRoute=${initialRoute.isNotEmpty ? initialRoute : "null"} flavor=${hasDebugBootstrap ? "dev" : "prod"}',
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
      flavor: hasDebugBootstrap ? AppFlavor.dev : AppFlavor.prod,
      appName: hasDebugBootstrap ? 'EliteSync Dev' : 'EliteSync',
      // The Android host app embeds the Flutter release AAR, which always
      // boots through main.dart -> main_prod.dart. Keep prod pointed at the
      // verified direct backend entry until the public domain chain is stable.
      apiBaseUrl: hasDebugBootstrap
          ? 'http://101.133.161.203/'
          : 'https://slowdate.top/',
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: hasDebugBootstrap,
      useMockHome: false,
      useMockMatch: hasDebugBootstrap,
      useMockChat: chatMockFromHost || chatMockFromDefine,
      useMockProfile: false,
      useMockAdmin: adminMockFromHost || adminMockFromDefine,
      initialRoute: initialRoute.isEmpty ? null : initialRoute,
      debugAccessToken: debugAccessToken,
      debugRefreshToken: debugRefreshToken,
      debugAutoLoginPhone: debugAutoLoginPhone,
      debugAutoLoginPassword: debugAutoLoginPassword,
    ),
  );
}
