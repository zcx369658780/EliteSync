import 'package:flutter_elitesync/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync/features/auth/domain/entities/auth_user.dart';

class AuthMapper {
  const AuthMapper();

  AuthSession toSession(LoginResponseDto dto) {
    final userJson = dto.user ?? const <String, dynamic>{};

    final user = AuthUser(
      id: (userJson['id'] as num?)?.toInt() ?? 0,
      phone: (userJson['phone'] as String?) ?? '',
      nickname: userJson['nickname'] as String?,
      city: userJson['city'] as String?,
      avatarUrl: userJson['avatar_url'] as String?,
      verified: (userJson['verified'] as bool?) ?? false,
    );

    return AuthSession(
      accessToken: dto.token ?? '',
      refreshToken: dto.refreshToken ?? '',
      user: user,
    );
  }
}
