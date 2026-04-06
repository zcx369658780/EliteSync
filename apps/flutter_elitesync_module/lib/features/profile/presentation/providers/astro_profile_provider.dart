import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_errors.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

Future<Map<String, dynamic>?> _fetchAstroProfile(
  Ref ref, {
  required String path,
  Map<String, dynamic>? query,
  String? fallbackPath,
  Map<String, dynamic>? fallbackQuery,
}) async {
  Future<NetworkResult<Map<String, dynamic>>> request(
    String requestPath,
    Map<String, dynamic>? requestQuery,
  ) {
    print('[ASTRO] request => $requestPath query=${requestQuery ?? const {}}');
    ref
        .read(appLoggerProvider)
        .info('[ASTRO] request => $requestPath query=${requestQuery ?? const {}}', tag: 'ASTRO');
    return ref
        .read(apiClientProvider)
        .get(requestPath, query: requestQuery)
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw const AstroProfileApiException(
            message: '星盘请求超时，请检查网络后重试。',
            statusCode: 504,
            code: 'timeout',
          ),
        );
  }

  NetworkResult<Map<String, dynamic>> result = await request(path, query);
  if (result is NetworkSuccess<Map<String, dynamic>>) {
    print('[ASTRO] success <= $path keys=${result.data.keys.join(",")}');
    ref
        .read(appLoggerProvider)
        .info('[ASTRO] success <= $path keys=${result.data.keys.join(",")}', tag: 'ASTRO');
    final exists = result.data['exists'] == true;
    if (!exists) return null;
    final profile = result.data['profile'];
    if (profile is Map<String, dynamic>) return profile;
    return null;
  }

  var failure = result as NetworkFailure<Map<String, dynamic>>;
  print(
    '[ASTRO] failure <= $path status=${failure.statusCode} code=${failure.code} message=${failure.message}',
  );
  ref
      .read(appLoggerProvider)
      .warning(
        '[ASTRO] failure <= $path status=${failure.statusCode} code=${failure.code} message=${failure.message}',
        tag: 'ASTRO',
      );
  if (failure.statusCode == 404 && fallbackPath != null) {
    result = await request(fallbackPath, fallbackQuery);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      print('[ASTRO] fallback success <= $fallbackPath keys=${result.data.keys.join(",")}');
      ref
          .read(appLoggerProvider)
          .info('[ASTRO] fallback success <= $fallbackPath keys=${result.data.keys.join(",")}', tag: 'ASTRO');
      final exists = result.data['exists'] == true;
      if (!exists) return null;
      final profile = result.data['profile'];
      if (profile is Map<String, dynamic>) return profile;
      return null;
    }
    failure = result as NetworkFailure<Map<String, dynamic>>;
    print(
      '[ASTRO] fallback failure <= $fallbackPath status=${failure.statusCode} code=${failure.code} message=${failure.message}',
    );
    ref
        .read(appLoggerProvider)
        .warning(
          '[ASTRO] fallback failure <= $fallbackPath status=${failure.statusCode} code=${failure.code} message=${failure.message}',
          tag: 'ASTRO',
        );
  }

  if (failure.statusCode == 401 || failure.statusCode == 403) {
    await ref.read(sessionProvider.notifier).setUnauthenticated();
  }

  throw AstroProfileApiException(
    message: failure.message,
    statusCode: failure.statusCode,
    code: failure.code,
  );
}

final astroSummaryProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return _fetchAstroProfile(
    ref,
    path: '/api/v1/profile/astro/summary',
    fallbackPath: '/api/v1/profile/astro',
    fallbackQuery: const {'include_chart': 0},
  );
});

final astroNatalChartProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return _fetchAstroProfile(
    ref,
    path: '/api/v1/profile/astro/chart',
    fallbackPath: '/api/v1/profile/astro',
  );
});

final astroChartPreviewProvider = FutureProvider<String?>((ref) async {
  final profile = await ref.watch(astroNatalChartProvider.future);
  if (profile == null) return null;
  final svg = (profile['natal_chart_svg'] ?? '').toString().trim();
  return svg.isEmpty ? null : svg;
});

final astroServerProfileProvider = astroSummaryProvider;
