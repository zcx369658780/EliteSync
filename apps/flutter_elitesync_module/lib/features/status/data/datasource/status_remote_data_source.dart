import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/status_mock.dart';

class StatusRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 4);

  StatusRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;

  Future<List<StatusPostEntity>> fetchStatusPosts({int limit = 20}) async {
    if (useMock) {
      return StatusMock.posts
          .map((e) => StatusPostEntity.fromJson(Map<String, dynamic>.from(e)))
          .take(limit)
          .toList();
    }

    try {
      final result = await apiClient
          .get('/api/v1/status/posts', query: {'limit': limit})
          .timeout(_requestTimeout);
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final list = result.data['items'] as List<dynamic>? ?? const [];
        return list
            .whereType<Map<String, dynamic>>()
            .map(StatusPostEntity.fromJson)
            .toList();
      }
      final failure = result as NetworkFailure<Map<String, dynamic>>;
      throw Exception(failure.message);
    } catch (_) {
      return StatusMock.posts
          .map((e) => StatusPostEntity.fromJson(Map<String, dynamic>.from(e)))
          .take(limit)
          .toList();
    }
  }

  Future<StatusPostEntity> createStatusPost({
    required String title,
    required String body,
    String? locationName,
    String visibility = 'public',
  }) async {
    if (useMock) {
      final payload = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'location_name': locationName ?? '同城',
        'visibility': visibility,
        'can_delete': true,
        'created_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
        'author': const {
          'id': 5,
          'name': 'SmokeUser',
          'phone': '17094346566',
          'role': 'user',
          'account_type': 'test',
          'is_square_visible': true,
        },
      };
      return StatusPostEntity.fromJson(payload);
    }

    final result = await apiClient
        .post(
          '/api/v1/status/posts',
          body: {
            'title': title,
            'body': body,
            if (locationName != null && locationName.trim().isNotEmpty)
              'location_name': locationName.trim(),
            'visibility': visibility,
          },
        )
        .timeout(_requestTimeout);

    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> deleteStatusPost(int postId) async {
    if (useMock) return;
    final result = await apiClient
        .delete('/api/v1/status/posts/$postId')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return;
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }
}
