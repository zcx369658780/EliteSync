class ProfileDetailEntity {
  const ProfileDetailEntity({
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
}
