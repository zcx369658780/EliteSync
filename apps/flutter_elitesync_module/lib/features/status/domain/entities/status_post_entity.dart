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
    required this.locationName,
    required this.visibility,
    required this.canDelete,
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
  final String locationName;
  final String visibility;
  final bool canDelete;
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
      locationName: (json['location_name'] ?? '').toString(),
      visibility: (json['visibility'] ?? 'public').toString(),
      canDelete: parseBool(json['can_delete']),
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
}
