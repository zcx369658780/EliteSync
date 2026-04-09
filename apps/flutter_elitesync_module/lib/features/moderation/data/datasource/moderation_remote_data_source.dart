import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModerationRemoteDataSource {
  const ModerationRemoteDataSource({
    required this.telemetry,
    required this.useMock,
  });

  final AppTelemetryService telemetry;
  final bool useMock;

  Future<NetworkResult<Map<String, dynamic>>> reportUser({
    required int targetUserId,
    required String category,
    required String reasonCode,
    required String sourcePage,
    String? detail,
    int? targetMessageId,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      return const NetworkSuccess(<String, dynamic>{'ok': true});
    }

    final result = await telemetry.postEvent(
      '/api/v1/moderation/reports',
      sourcePage: sourcePage,
      body: {
        'target_user_id': targetUserId,
        'category': category,
        'reason_code': reasonCode,
        if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
        if (targetMessageId != null && targetMessageId > 0) 'target_message_id': targetMessageId,
      },
    );

    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
    return result;
  }

  Future<NetworkResult<Map<String, dynamic>>> blockUser({
    required int blockedUserId,
    required String sourcePage,
    String? reasonCode,
    String? detail,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      return const NetworkSuccess(<String, dynamic>{'ok': true});
    }

    final result = await telemetry.postEvent(
      '/api/v1/moderation/blocks',
      sourcePage: sourcePage,
      body: {
        'blocked_user_id': blockedUserId,
        if (reasonCode != null && reasonCode.trim().isNotEmpty) 'reason_code': reasonCode.trim(),
        if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
      },
    );

    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
    return result;
  }
}

final moderationRemoteDataSourceProvider = Provider<ModerationRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ModerationRemoteDataSource(
    telemetry: ref.watch(appTelemetryProvider),
    useMock: env.useMockData,
  );
});
