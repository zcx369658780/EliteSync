class StatusPostEntity {
  const StatusPostEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.authorId,
    required this.authorName,
    required this.authorPhone,
    required this.authorRole,
    required this.authorAccountType,
    required this.authorIsSynthetic,
    required this.authorCity,
    required this.authorRelationshipGoal,
    required this.authorPublicMbti,
    required this.authorPublicPersonality,
    required this.locationName,
    required this.visibility,
    required this.canDelete,
    required this.likesCount,
    required this.likedByViewer,
    required this.coverMediaAssetId,
    required this.coverMediaUrl,
    required this.createdAt,
    required this.isDeleted,
  });

  final int id;
  final String title;
  final String body;
  final int authorId;
  final String authorName;
  final String authorPhone;
  final String authorRole;
  final String authorAccountType;
  final bool authorIsSynthetic;
  final String authorCity;
  final String authorRelationshipGoal;
  final String authorPublicMbti;
  final List<String> authorPublicPersonality;
  final String locationName;
  final String visibility;
  final bool canDelete;
  final int likesCount;
  final bool likedByViewer;
  final int? coverMediaAssetId;
  final String? coverMediaUrl;
  final DateTime createdAt;
  final bool isDeleted;

  factory StatusPostEntity.fromJson(Map<String, dynamic> json) {
    final author = json['author'] is Map<String, dynamic>
        ? (json['author'] as Map<String, dynamic>)
        : <String, dynamic>{};
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is num) return value != 0;
      if (value is String) {
        final normalized = value.toLowerCase().trim();
        if (normalized == 'true' || normalized == '1') return true;
        if (normalized == 'false' || normalized == '0') return false;
      }
      return false;
    }
    int parseInt(dynamic value) {
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    return StatusPostEntity(
      id: parseInt(json['id']),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      authorId: parseInt(author['id']),
      authorName: (author['name'] ?? '').toString(),
      authorPhone: (author['phone'] ?? '').toString(),
      authorRole: (author['role'] ?? 'user').toString(),
      authorAccountType: (author['account_type'] ?? 'normal').toString(),
      authorIsSynthetic: parseBool(author['is_synthetic']),
      authorCity: (author['city'] ?? '').toString(),
      authorRelationshipGoal: (author['relationship_goal'] ?? '').toString(),
      authorPublicMbti: (author['public_mbti'] ?? '').toString(),
      authorPublicPersonality:
          (author['public_personality'] as List<dynamic>? ?? const [])
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList(),
      locationName: (json['location_name'] ?? '').toString(),
      visibility: (json['visibility'] ?? 'public').toString(),
      canDelete: parseBool(json['can_delete']),
      likesCount: parseInt(json['likes_count']),
      likedByViewer: parseBool(json['liked_by_viewer']),
      coverMediaAssetId:
          (json['cover_media_asset_id'] as num?)?.toInt() ??
          (json['cover_media'] is Map<String, dynamic>
              ? parseInt((json['cover_media'] as Map<String, dynamic>)['id'])
              : null),
      coverMediaUrl: json['cover_media'] is Map<String, dynamic>
          ? ((json['cover_media'] as Map<String, dynamic>)['public_url'] ?? '')
              .toString()
          : ((json['media'] as List<dynamic>? ?? const [])
                  .cast<dynamic>()
                  .isNotEmpty
              ? (json['media'] as List<dynamic>).first.toString()
              : null),
      createdAt:
          DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isDeleted: parseBool(json['is_deleted']),
    );
  }

  bool get isPublic => visibility == 'public' || visibility == 'square';

  String get visibilityLabel {
    return switch (visibility) {
      'private' => '仅自己可见',
      'square' => '广场可见',
      _ => '公开',
    };
  }

  String get visibilityTierLabel {
    return switch (visibility) {
      'private' => '私密层',
      'square' => '广场层',
      _ => '公开层',
    };
  }

  String get authorLayerLabel {
    if (authorIsSynthetic) {
      return '合成账号';
    }
    return switch (authorAccountType) {
      'test' => '测试账号',
      _ => '真实账号',
    };
  }

  String get authorLayerBadge {
    return '$authorLayerLabel · $visibilityLabel';
  }

  String get displayAuthorName => authorName.isNotEmpty ? authorName : '未知用户';

  bool get hasMedia => (coverMediaUrl ?? '').isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'location_name': locationName,
      'visibility': visibility,
      'is_deleted': isDeleted,
      'can_delete': canDelete,
      'likes_count': likesCount,
      'liked_by_viewer': likedByViewer,
      'cover_media_asset_id': coverMediaAssetId,
      'cover_media': coverMediaUrl == null
          ? null
          : {
              'id': coverMediaAssetId,
              'public_url': coverMediaUrl,
            },
      'media': coverMediaUrl == null ? const [] : [coverMediaUrl],
      'created_at': createdAt.toIso8601String(),
      'author': {
        'id': authorId,
        'name': authorName,
        'nickname': authorName,
        'phone': authorPhone,
        'role': authorRole,
        'account_type': authorAccountType,
        'is_synthetic': authorIsSynthetic,
        'city': authorCity,
        'relationship_goal': authorRelationshipGoal,
        'public_mbti': authorPublicMbti,
        'public_personality': authorPublicPersonality,
      },
    };
  }
}
