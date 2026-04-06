class ProfileSummaryDto {
  const ProfileSummaryDto({
    required this.nickname,
    required this.birthday,
    required this.birthTime,
    required this.birthPlace,
    required this.city,
    required this.target,
    required this.verified,
    required this.moderationStatus,
    required this.moderationNote,
    required this.completion,
    required this.tags,
  });
  final String nickname;
  final String birthday;
  final String birthTime;
  final String? birthPlace;
  final String city;
  final String target;
  final bool verified;
  final String moderationStatus;
  final String? moderationNote;
  final double completion;
  final List<String> tags;

  factory ProfileSummaryDto.fromJson(Map<String, dynamic> json) => ProfileSummaryDto(
        nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
        birthday: (json['birthday'] ?? '').toString(),
        birthTime: (json['birth_time'] ?? json['birthTime'] ?? '').toString(),
        birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
            ? null
            : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
        verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
        moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
        moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
            ? null
            : (json['moderation_note'] ?? '').toString(),
        completion: (json['completion'] as num?)?.toDouble() ?? 0.8,
        tags: (json['tags'] as List<dynamic>? ?? const ['资料已同步']).map((e) => e.toString()).toList(),
      );
}
