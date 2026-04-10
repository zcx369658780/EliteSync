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
    required this.accountType,
    required this.isSynthetic,
    required this.isMatchEligible,
    required this.isSquareVisible,
    required this.excludeFromMetrics,
    required this.syntheticBatch,
    required this.syntheticBatchId,
    required this.syntheticSeed,
    required this.generationVersion,
    required this.accountStatus,
    required this.visibilityScope,
    required this.cleanupToken,
    required this.bannedReason,
  });

  final int id;
  final String phone;
  final String name;
  final bool disabled;
  final String moderationStatus;
  final String verifyStatus;
  final String accountType;
  final bool isSynthetic;
  final bool isMatchEligible;
  final bool isSquareVisible;
  final bool excludeFromMetrics;
  final String syntheticBatch;
  final String syntheticBatchId;
  final int? syntheticSeed;
  final String generationVersion;
  final String accountStatus;
  final String visibilityScope;
  final String cleanupToken;
  final String bannedReason;

  factory AdminModerationUserEntity.fromJson(Map<String, dynamic> json) {
    return AdminModerationUserEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: (json['phone'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      disabled: (json['disabled'] as bool?) ?? false,
      moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
      verifyStatus: (json['verify_status'] ?? '').toString(),
      accountType: (json['account_type'] ?? 'normal').toString(),
      isSynthetic: (json['is_synthetic'] as bool?) ?? false,
      isMatchEligible: (json['is_match_eligible'] as bool?) ?? true,
      isSquareVisible: (json['is_square_visible'] as bool?) ?? true,
      excludeFromMetrics: (json['exclude_from_metrics'] as bool?) ?? false,
      syntheticBatch: (json['synthetic_batch'] ?? '').toString(),
      syntheticBatchId: (json['synthetic_batch_id'] ?? '').toString(),
      syntheticSeed: (json['synthetic_seed'] as num?)?.toInt(),
      generationVersion: (json['generation_version'] ?? 'v1').toString(),
      accountStatus: (json['account_status'] ?? 'active').toString(),
      visibilityScope: (json['visibility_scope'] ?? 'square').toString(),
      cleanupToken: (json['cleanup_token'] ?? '').toString(),
      bannedReason: (json['banned_reason'] ?? '').toString(),
    );
  }
}
