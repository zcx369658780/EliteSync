class ProfileDetailDto {
  const ProfileDetailDto({
    required this.nickname,
    required this.gender,
    required this.birthday,
    required this.birthTime,
    required this.city,
    required this.target,
    this.birthPlace,
    this.birthLat,
    this.birthLng,
  });
  final String nickname;
  final String gender;
  final String birthday;
  final String birthTime;
  final String city;
  final String target;
  final String? birthPlace;
  final double? birthLat;
  final double? birthLng;

  factory ProfileDetailDto.fromJson(Map<String, dynamic> json) => ProfileDetailDto(
        nickname: (json['nickname'] ?? json['name'] ?? '').toString(),
        gender: (json['gender'] ?? '').toString(),
        birthday: (json['birthday'] ?? '').toString(),
        birthTime: (json['birth_time'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        target: (json['target'] ?? json['relationship_goal'] ?? '').toString(),
        birthPlace: (json['birth_place'] ?? json['private_birth_place'] ?? '').toString().isEmpty
            ? null
            : (json['birth_place'] ?? json['private_birth_place'] ?? '').toString(),
        birthLat: (json['birth_lat'] as num?)?.toDouble() ?? (json['private_birth_lat'] as num?)?.toDouble(),
        birthLng: (json['birth_lng'] as num?)?.toDouble() ?? (json['private_birth_lng'] as num?)?.toDouble(),
      );
}
