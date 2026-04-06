import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ModerationRemoteDataSource {
  const ModerationRemoteDataSource({
    required this.apiClient,
    required this.useMock,
  });

  final ApiClient apiClient;
  final bool useMock;

  Future<void> reportUser({
    required int targetUserId,
    required String category,
    required String reasonCode,
    String? detail,
    int? targetMessageId,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 220));
      return;
    }

    final result = await apiClient.post('/api/v1/moderation/reports', body: {
      'target_user_id': targetUserId,
      'category': category,
      'reason_code': reasonCode,
      if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
      if (targetMessageId != null && targetMessageId > 0) 'target_message_id': targetMessageId,
    });

    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> blockUser({
    required int blockedUserId,
    String? reasonCode,
    String? detail,
  }) async {
    if (useMock) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
      return;
    }

    final result = await apiClient.post('/api/v1/moderation/blocks', body: {
      'blocked_user_id': blockedUserId,
      if (reasonCode != null && reasonCode.trim().isNotEmpty) 'reason_code': reasonCode.trim(),
      if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
    });

    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}

final moderationRemoteDataSourceProvider = Provider<ModerationRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ModerationRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockData,
  );
});
