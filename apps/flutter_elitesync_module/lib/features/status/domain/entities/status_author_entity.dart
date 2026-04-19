import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';

class StatusAuthorEntity {
  const StatusAuthorEntity({
    required this.id,
    required this.name,
    required this.nickname,
    required this.phone,
    required this.city,
    required this.relationshipGoal,
    required this.publicMbti,
    required this.publicPersonality,
    required this.isSynthetic,
    required this.isSquareVisible,
    required this.statusCount,
    required this.recentPosts,
  });

  final int id;
  final String name;
  final String nickname;
  final String phone;
  final String city;
  final String relationshipGoal;
  final String publicMbti;
  final List<String> publicPersonality;
  final bool isSynthetic;
  final bool isSquareVisible;
  final int statusCount;
  final List<StatusPostEntity> recentPosts;

  String get displayName => nickname.isNotEmpty ? nickname : name;

  factory StatusAuthorEntity.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? json['author'] as Map<String, dynamic>
        : <String, dynamic>{};
    final recent = json['items'] as List<dynamic>? ?? const [];
    return StatusAuthorEntity(
      id: (author['id'] as num?)?.toInt() ?? 0,
      name: (author['name'] ?? '').toString(),
      nickname: (author['nickname'] ?? '').toString(),
      phone: (author['phone'] ?? '').toString(),
      city: (author['city'] ?? '').toString(),
      relationshipGoal: (author['relationship_goal'] ?? '').toString(),
      publicMbti: (author['public_mbti'] ?? '').toString(),
      publicPersonality:
          (author['public_personality'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList(),
      isSynthetic: (author['is_synthetic'] as bool?) ?? false,
      isSquareVisible: (author['is_square_visible'] as bool?) ?? true,
      statusCount: (json['total'] as num?)?.toInt() ?? recent.length,
      recentPosts: recent
          .whereType<Map<String, dynamic>>()
          .map(StatusPostEntity.fromJson)
          .toList(),
    );
  }
}
