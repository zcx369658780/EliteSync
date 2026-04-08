import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/core/error/error_mapper.dart';
import 'package:flutter_elitesync_module/core/logging/app_logger.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/dio_factory.dart';
import 'package:flutter_elitesync_module/core/network/interceptors/auth_interceptor.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';

final appEnvProvider = Provider<AppEnv>((ref) {
  throw UnimplementedError('appEnvProvider must be overridden in bootstrap');
});

final appLoggerProvider = Provider<AppLogger>((ref) {
  final env = ref.watch(appEnvProvider);
  return AppLogger(enableDebugLogs: env.isDev);
});

final errorMapperProvider = Provider<ErrorMapper>((ref) {
  return const ErrorMapper();
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final accessTokenProvider = Provider<AccessTokenProvider>((ref) {
  return () async {
    final env = ref.read(appEnvProvider);
    if (env.debugAccessToken.isNotEmpty) {
      return env.debugAccessToken;
    }
    return ref.read(secureStorageProvider).read(CacheKeys.accessToken);
  };
});

final refreshAccessTokenProvider = Provider<RefreshAccessToken>((ref) {
  return () async {
    // 目前没有真实 refresh token 流程。
    // 不要返回旧 access token 做伪刷新，否则 401 会被重试并掩盖成长时间 loading。
    return null;
  };
});

final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(appEnvProvider);
  final logger = ref.watch(appLoggerProvider);
  final tokenProvider = ref.watch(accessTokenProvider);
  final refreshProvider = ref.watch(refreshAccessTokenProvider);

  final factory = DioFactory(
    env: env,
    logger: logger,
    accessTokenProvider: tokenProvider,
    refreshAccessToken: refreshProvider,
  );

  return factory.create();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(dio: ref.watch(dioProvider));
});
