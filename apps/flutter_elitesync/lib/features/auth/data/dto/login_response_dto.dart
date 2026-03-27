class LoginResponseDto {
  const LoginResponseDto({
    required this.ok,
    this.token,
    this.refreshToken,
    this.user,
    this.message,
    this.code,
  });

  final bool ok;
  final String? token;
  final String? refreshToken;
  final Map<String, dynamic>? user;
  final String? message;
  final String? code;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      ok: (json['ok'] as bool?) ?? false,
      token: json['token'] as String?,
      refreshToken: json['refresh_token'] as String?,
      user: json['user'] as Map<String, dynamic>?,
      message: json['message'] as String?,
      code: json['code'] as String?,
    );
  }
}
