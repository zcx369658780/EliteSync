class RegisterRequestDto {
  const RegisterRequestDto({
    required this.phone,
    required this.password,
    this.nickname,
  });

  final String phone;
  final String password;
  final String? nickname;

  Map<String, dynamic> toJson() {
    return {'phone': phone, 'password': password, 'nickname': nickname};
  }
}
