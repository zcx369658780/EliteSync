class UserSummary {
  const UserSummary({
    required this.id,
    required this.phone,
    this.nickname,
    this.city,
    this.avatarUrl,
    this.verified = false,
  });

  final int id;
  final String phone;
  final String? nickname;
  final String? city;
  final String? avatarUrl;
  final bool verified;

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: (json['phone'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? (json['name'] as String?),
      city: json['city'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'city': city,
      'avatar_url': avatarUrl,
      'verified': verified,
    };
  }
}
