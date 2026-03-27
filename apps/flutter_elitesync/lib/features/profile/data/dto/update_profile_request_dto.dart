class UpdateProfileRequestDto {
  const UpdateProfileRequestDto({
    required this.nickname,
    required this.gender,
    required this.birthday,
    required this.city,
    required this.target,
  });

  final String nickname;
  final String gender;
  final String birthday;
  final String city;
  final String target;

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'gender': gender,
        'birthday': birthday,
        'city': city,
        'target': target,
      };
}
