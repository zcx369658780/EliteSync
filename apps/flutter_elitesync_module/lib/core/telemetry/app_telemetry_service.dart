import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AppTelemetryService {
  const AppTelemetryService({
    required this.apiClient,
    required this.appVersionProvider,
  });

  final ApiClient apiClient;
  final Future<String> Function() appVersionProvider;

  Future<NetworkResult<Map<String, dynamic>>> postEvent(
    String path, {
    required String sourcePage,
    Object? body,
  }) async {
    final version = await appVersionProvider();
    return apiClient.post(
      path,
      body: body,
      options: Options(
        headers: {
          'X-App-Version': version,
          'X-Source-Page': sourcePage,
        },
      ),
    );
  }

  Future<NetworkResult<Map<String, dynamic>>> trackEvent(
    String eventName, {
    required String sourcePage,
    int? targetUserId,
    int? matchId,
    Map<String, dynamic>? payload,
  }) async {
    final body = <String, dynamic>{
      'event_name': eventName,
      if (targetUserId != null) 'target_user_id': targetUserId,
      if (matchId != null) 'match_id': matchId,
      if (payload != null && payload.isNotEmpty) 'payload': payload,
    };
    return postEvent(
      '/api/v1/telemetry/events',
      sourcePage: sourcePage,
      body: body,
    );
  }

  Future<NetworkResult<Map<String, dynamic>>> getEvent(
    String path, {
    required String sourcePage,
    Map<String, dynamic>? query,
  }) async {
    final version = await appVersionProvider();
    return apiClient.get(
      path,
      query: query,
      options: Options(
        headers: {
          'X-App-Version': version,
          'X-Source-Page': sourcePage,
        },
      ),
    );
  }
}

final appVersionProvider = Provider<Future<String> Function()>((ref) {
  return () async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  };
});

final appTelemetryProvider = Provider<AppTelemetryService>((ref) {
  return AppTelemetryService(
    apiClient: ref.watch(apiClientProvider),
    appVersionProvider: ref.watch(appVersionProvider),
  );
});
