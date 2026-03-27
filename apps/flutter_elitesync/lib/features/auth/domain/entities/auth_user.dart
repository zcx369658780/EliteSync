class AuthUser {
  const AuthUser({
    required this.id,
    required this.phone,
    this.nickname,
    this.city,
    this.avatarUrl,
    this.verified = false,
  });

  final int id;
  final String phone;
  final String? nickname;
  final String? city;
  final String? avatarUrl;
  final bool verified;
}
