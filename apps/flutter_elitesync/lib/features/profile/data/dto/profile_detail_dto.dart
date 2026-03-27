class ProfileDetailDto {
  const ProfileDetailDto({required this.nickname, required this.gender, required this.birthday, required this.city, required this.target});
  final String nickname;
  final String gender;
  final String birthday;
  final String city;
  final String target;

  factory ProfileDetailDto.fromJson(Map<String, dynamic> json) => ProfileDetailDto(
        nickname: (json['nickname'] ?? '').toString(),
        gender: (json['gender'] ?? '').toString(),
        birthday: (json['birthday'] ?? '').toString(),
        city: (json['city'] ?? '').toString(),
        target: (json['target'] ?? '').toString(),
      );
}
