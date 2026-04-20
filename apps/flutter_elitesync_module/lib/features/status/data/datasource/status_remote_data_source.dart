import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_author_entity.dart';
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
    int? coverMediaAssetId,
  }) async {
    if (useMock) {
      final payload = <String, dynamic>{
        'id': DateTime.now().millisecondsSinceEpoch,
        'title': title,
        'body': body,
        'location_name': locationName ?? '同城',
        'visibility': visibility,
        'can_delete': true,
        'likes_count': 0,
        'liked_by_viewer': false,
        'created_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
        'cover_media_asset_id': coverMediaAssetId,
        'author': const {
          'id': 5,
          'name': 'SmokeUser',
          'phone': '17094346566',
          'role': 'user',
          'account_type': 'test',
          'is_square_visible': true,
          'nickname': 'SmokeUser',
          'city': '南阳',
          'relationship_goal': 'dating',
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
            if (coverMediaAssetId != null && coverMediaAssetId > 0)
              'cover_media_asset_id': coverMediaAssetId,
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

  Future<StatusPostEntity> fetchStatusPost(int postId) async {
    if (useMock) {
      final match = StatusMock.posts.firstWhere(
        (e) => (e['id'] as num?)?.toInt() == postId,
        orElse: () => StatusMock.posts.first,
      );
      return StatusPostEntity.fromJson(Map<String, dynamic>.from(match));
    }
    final result = await apiClient
        .get('/api/v1/status/posts/$postId')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<StatusPostEntity>> fetchAuthorStatuses(int userId) async {
    if (useMock) {
      return StatusMock.posts
          .map((e) => StatusPostEntity.fromJson(Map<String, dynamic>.from(e)))
          .where((post) => post.authorId == userId)
          .toList();
    }
    final result = await apiClient
        .get('/api/v1/status/authors/$userId')
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
  }

  Future<StatusAuthorEntity> fetchAuthorProfile(int userId) async {
    if (useMock) {
      final posts = await fetchAuthorStatuses(userId);
      final author = posts.isNotEmpty
          ? {
              'id': posts.first.authorId,
              'name': posts.first.authorName,
              'nickname': posts.first.authorName,
              'phone': posts.first.authorPhone,
              'city': posts.first.authorCity,
              'relationship_goal': posts.first.authorRelationshipGoal,
              'public_mbti': posts.first.authorPublicMbti,
              'public_personality': posts.first.authorPublicPersonality,
              'is_synthetic': posts.first.authorIsSynthetic,
              'is_square_visible': true,
            }
          : {
              'id': userId,
              'name': '用户 $userId',
              'nickname': '用户 $userId',
              'phone': '',
              'city': '',
              'relationship_goal': '',
              'public_mbti': '',
              'public_personality': const [],
              'is_synthetic': false,
              'is_square_visible': true,
            };
      return StatusAuthorEntity.fromJson({
        'author': author,
        'items': posts.map((e) => e.toJson()).toList(),
        'total': posts.length,
      });
    }
    final result = await apiClient
        .get('/api/v1/status/authors/$userId')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return StatusAuthorEntity.fromJson(result.data);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusPostEntity> likeStatusPost(int postId) async {
    if (useMock) {
      return fetchStatusPost(postId);
    }
    final result = await apiClient
        .post('/api/v1/status/posts/$postId/likes')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<StatusPostEntity> unlikeStatusPost(int postId) async {
    if (useMock) {
      return fetchStatusPost(postId);
    }
    final result = await apiClient
        .delete('/api/v1/status/posts/$postId/likes')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final item = result.data['item'] as Map<String, dynamic>? ?? const {};
      return StatusPostEntity.fromJson(item);
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> reportStatusPost({
    required int postId,
    required String reasonCode,
    String? detail,
  }) async {
    if (useMock) return;
    final result = await apiClient
        .post(
          '/api/v1/status/posts/$postId/report',
          body: {
            'reason_code': reasonCode,
            if (detail != null && detail.trim().isNotEmpty) 'detail': detail.trim(),
          },
        )
        .timeout(_requestTimeout);
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
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
