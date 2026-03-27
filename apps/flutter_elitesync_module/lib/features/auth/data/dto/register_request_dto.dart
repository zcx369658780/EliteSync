class RegisterRequestDto {
  const RegisterRequestDto({
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.realnameVerified,
    this.nickname,
  });

  final String phone;
  final String password;
  final String passwordConfirmation;
  final bool realnameVerified;
  final String? nickname;

  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      // Backend current key is `name`; keep nickname as fallback compatibility.
      'name': nickname,
      'nickname': nickname,
      'realname_verified': realnameVerified,
    };
  }
}
