import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_user.dart';

class AuthMapper {
  const AuthMapper();

  double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value.trim());
      if (parsed != null) return parsed;
    }
    return null;
  }

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
      birthLat: _asDouble(userJson['birth_lat']) ?? _asDouble(userJson['private_birth_lat']),
      birthLng: _asDouble(userJson['birth_lng']) ?? _asDouble(userJson['private_birth_lng']),
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
