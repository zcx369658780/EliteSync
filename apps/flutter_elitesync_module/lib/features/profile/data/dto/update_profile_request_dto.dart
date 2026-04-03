class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({
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

  Map<String, dynamic> toJson() => {
        'name': nickname,
        'gender': gender,
        'birthday': birthday,
        'birth_time': birthTime,
        'city': city,
        'relationship_goal': target,
        if (birthPlace != null) 'birth_place': birthPlace,
        if (birthLat != null) 'birth_lat': birthLat,
        if (birthLng != null) 'birth_lng': birthLng,
      };
}
