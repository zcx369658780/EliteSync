class AdminModerationUserRef {
  const AdminModerationUserRef({
    required this.id,
    required this.name,
    required this.phone,
    required this.disabled,
    required this.moderationStatus,
  });

  final int? id;
  final String name;
  final String phone;
  final bool disabled;
  final String moderationStatus;

  factory AdminModerationUserRef.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return AdminModerationUserRef(
      id: (map['id'] as num?)?.toInt(),
      name: (map['name'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      disabled: (map['disabled'] as bool?) ?? false,
      moderationStatus: (map['moderation_status'] ?? 'normal').toString(),
    );
  }
}

class AdminModerationReportEntity {
  const AdminModerationReportEntity({
    required this.id,
    required this.status,
    required this.appealStatus,
    required this.category,
    required this.reasonCode,
    required this.detail,
    required this.appealNote,
    required this.adminNote,
    required this.reporter,
    required this.targetUser,
    required this.resolver,
    required this.appealedAt,
    required this.resolvedAt,
  });

  final int id;
  final String status;
  final String appealStatus;
  final String category;
  final String reasonCode;
  final String detail;
  final String appealNote;
  final String adminNote;
  final AdminModerationUserRef reporter;
  final AdminModerationUserRef targetUser;
  final AdminModerationUserRef resolver;
  final DateTime? appealedAt;
  final DateTime? resolvedAt;

  factory AdminModerationReportEntity.fromJson(Map<String, dynamic> json) {
    return AdminModerationReportEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      status: (json['status'] ?? '').toString(),
      appealStatus: (json['appeal_status'] ?? '').toString(),
      category: (json['category'] ?? '').toString(),
      reasonCode: (json['reason_code'] ?? '').toString(),
      detail: (json['detail'] ?? '').toString(),
      appealNote: (json['appeal_note'] ?? '').toString(),
      adminNote: (json['admin_note'] ?? '').toString(),
      reporter: AdminModerationUserRef.fromJson(
        (json['reporter'] as Map<String, dynamic>?) ?? const {},
      ),
      targetUser: AdminModerationUserRef.fromJson(
        (json['target_user'] as Map<String, dynamic>?) ?? const {},
      ),
      resolver: AdminModerationUserRef.fromJson(
        (json['resolver'] as Map<String, dynamic>?) ?? const {},
      ),
      appealedAt: DateTime.tryParse((json['appealed_at'] ?? '').toString()),
      resolvedAt: DateTime.tryParse((json['resolved_at'] ?? '').toString()),
    );
  }
}

class AdminModerationUserEntity {
  const AdminModerationUserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.disabled,
    required this.moderationStatus,
    required this.verifyStatus,
    required this.isSynthetic,
    required this.syntheticBatch,
  });

  final int id;
  final String phone;
  final String name;
  final bool disabled;
  final String moderationStatus;
  final String verifyStatus;
  final bool isSynthetic;
  final String syntheticBatch;

  factory AdminModerationUserEntity.fromJson(Map<String, dynamic> json) {
    return AdminModerationUserEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: (json['phone'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      disabled: (json['disabled'] as bool?) ?? false,
      moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
      verifyStatus: (json['verify_status'] ?? '').toString(),
      isSynthetic: (json['is_synthetic'] as bool?) ?? false,
      syntheticBatch: (json['synthetic_batch'] ?? '').toString(),
    );
  }
}
