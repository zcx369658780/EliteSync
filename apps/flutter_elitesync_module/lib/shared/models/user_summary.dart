class UserSummary {
  const UserSummary({
    required this.id,
    required this.phone,
    this.nickname,
    this.birthday,
    this.birthTime,
    this.gender,
    this.city,
    this.relationshipGoal,
    this.birthPlace,
    this.birthLat,
    this.birthLng,
    this.avatarUrl,
    this.verified = false,
    this.moderationStatus = 'normal',
    this.moderationNote,
  });

  final int id;
  final String phone;
  final String? nickname;
  final String? birthday;
  final String? birthTime;
  final String? gender;
  final String? city;
  final String? relationshipGoal;
  final String? birthPlace;
  final double? birthLat;
  final double? birthLng;
  final String? avatarUrl;
  final bool verified;
  final String moderationStatus;
  final String? moderationNote;

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

  factory UserSummary.fromJson(Map<String, dynamic> json) {
    return UserSummary(
      id: (json['id'] as num?)?.toInt() ?? 0,
      phone: (json['phone'] as String?) ?? '',
      nickname: (json['nickname'] as String?) ?? (json['name'] as String?),
      birthday: json['birthday'] as String?,
      birthTime: (json['birth_time'] as String?) ?? (json['birthTime'] as String?),
      gender: json['gender'] as String?,
      city: json['city'] as String?,
      relationshipGoal:
          (json['relationship_goal'] as String?) ??
          (json['target'] as String?),
      birthPlace: (json['birth_place'] as String?) ?? (json['private_birth_place'] as String?),
      birthLat: _asDouble(json['birth_lat']) ?? _asDouble(json['private_birth_lat']),
      birthLng: _asDouble(json['birth_lng']) ?? _asDouble(json['private_birth_lng']),
      avatarUrl: json['avatar_url'] as String?,
      verified: (json['verified'] as bool?) ?? (json['realname_verified'] as bool?) ?? false,
      moderationStatus: (json['moderation_status'] ?? 'normal').toString(),
      moderationNote: (json['moderation_note'] ?? '').toString().isEmpty
          ? null
          : (json['moderation_note'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'nickname': nickname,
      'birthday': birthday,
      'birth_time': birthTime,
      'gender': gender,
      'city': city,
      'relationship_goal': relationshipGoal,
      'birth_place': birthPlace,
      'birth_lat': birthLat,
      'birth_lng': birthLng,
      'avatar_url': avatarUrl,
      'verified': verified,
      'moderation_status': moderationStatus,
      'moderation_note': moderationNote,
    };
  }
}
