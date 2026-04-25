import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';

class NotificationRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 4);

  NotificationRemoteDataSource({
    required this.apiClient,
    required this.useMock,
  });

  final ApiClient apiClient;
  final bool useMock;

  Future<List<NotificationItemEntity>> fetchNotifications({int limit = 50}) async {
    if (useMock) {
      return const <NotificationItemEntity>[];
    }

    final result = await apiClient
        .get('/api/v1/notifications', query: {'limit': limit})
        .timeout(_requestTimeout);

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = (result.data['items'] as List<dynamic>? ?? const []);
      return list
          .whereType<Map<String, dynamic>>()
          .map(NotificationItemEntity.fromJson)
          .toList();
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<int> fetchUnreadCount() async {
    if (useMock) {
      return 0;
    }

    final result = await apiClient
        .get('/api/v1/notifications/unread-count')
        .timeout(_requestTimeout);

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return (result.data['unread_total'] as num?)?.toInt() ?? 0;
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> markRead(int notificationId) async {
    if (useMock) return;
    final result = await apiClient
        .post('/api/v1/notifications/$notificationId/read')
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  Future<void> markAllRead() async {
    if (useMock) return;
    final result = await apiClient
        .post('/api/v1/notifications/read-all')
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
