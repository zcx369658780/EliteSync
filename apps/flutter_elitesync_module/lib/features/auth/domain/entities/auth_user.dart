class AuthUser {
  const AuthUser({
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
}
