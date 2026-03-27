class ProfileSummaryDto {
  const ProfileSummaryDto({required this.nickname, required this.city, required this.verified, required this.completion, required this.tags});
  final String nickname;
  final String city;
  final bool verified;
  final double completion;
  final List<String> tags;

  factory ProfileSummaryDto.fromJson(Map<String, dynamic> json) => ProfileSummaryDto(
        nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
        completion: (json['completion'] as num?)?.toDouble() ?? 0.8,
        tags: (json['tags'] as List<dynamic>? ?? const ['资料已同步']).map((e) => e.toString()).toList(),
      );
}
