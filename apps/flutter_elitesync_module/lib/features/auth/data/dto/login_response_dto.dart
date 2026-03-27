class LoginResponseDto {
  const LoginResponseDto({
    required this.ok,
    this.accessToken,
    this.refreshToken,
    this.tokenType,
    this.user,
    this.message,
    this.code,
  });

  final bool ok;
  final String? accessToken;
  final String? refreshToken;
  final String? tokenType;
  final Map<String, dynamic>? user;
  final String? message;
  final String? code;

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    final accessToken =
        (json['access_token'] as String?) ?? (json['token'] as String?);
    final user = json['user'] as Map<String, dynamic>?;
    final explicitOk = json['ok'] as bool?;
    return LoginResponseDto(
      ok: explicitOk ?? (accessToken != null && accessToken.isNotEmpty),
      accessToken: accessToken,
      refreshToken: json['refresh_token'] as String?,
      tokenType: json['token_type'] as String?,
      user: user,
      message: json['message'] as String?,
      code: json['code'] as String?,
    );
  }
}
