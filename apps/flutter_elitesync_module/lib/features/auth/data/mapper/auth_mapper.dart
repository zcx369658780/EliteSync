import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_user.dart';

class AuthMapper {
  const AuthMapper();

  AuthSession toSession(LoginResponseDto dto) {
    final userJson = dto.user ?? const <String, dynamic>{};

    final user = AuthUser(
      id: (userJson['id'] as num?)?.toInt() ?? 0,
      phone: (userJson['phone'] as String?) ?? '',
      nickname:
          (userJson['nickname'] as String?) ?? (userJson['name'] as String?),
      birthday: userJson['birthday'] as String?,
      birthTime: userJson['birth_time'] as String?,
      gender: userJson['gender'] as String?,
      city: userJson['city'] as String?,
      relationshipGoal:
          (userJson['relationship_goal'] as String?) ??
          (userJson['target'] as String?),
      birthPlace: (userJson['birth_place'] as String?) ?? (userJson['private_birth_place'] as String?),
      birthLat: (userJson['birth_lat'] as num?)?.toDouble() ?? (userJson['private_birth_lat'] as num?)?.toDouble(),
      birthLng: (userJson['birth_lng'] as num?)?.toDouble() ?? (userJson['private_birth_lng'] as num?)?.toDouble(),
      avatarUrl: userJson['avatar_url'] as String?,
      verified:
          (userJson['verified'] as bool?) ??
          (userJson['realname_verified'] as bool?) ??
          false,
    );

    return AuthSession(
      accessToken: dto.accessToken ?? '',
      refreshToken: dto.refreshToken ?? '',
      user: user,
    );
  }
}
