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
    return ref.read(secureStorageProvider).read(CacheKeys.accessToken);
  };
});

final refreshAccessTokenProvider = Provider<RefreshAccessToken>((ref) {
  return () async {
    // T10 再接真实刷新逻辑；当前返回现有 token 作为占位。
    return ref.read(secureStorageProvider).read(CacheKeys.accessToken);
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
