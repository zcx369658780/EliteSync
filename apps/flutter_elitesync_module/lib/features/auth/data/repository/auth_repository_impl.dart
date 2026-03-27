import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_request_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/register_request_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required AuthMapper mapper,
  }) : _remote = remote,
       _local = local,
       _mapper = mapper;

  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final AuthMapper _mapper;

  @override
  Future<AuthSession> login({
    required String phone,
    required String password,
  }) async {
    final response = await _remote.login(
      LoginRequestDto(phone: phone, password: password),
    );

    if (!response.ok) {
      throw ValidationException(
        response.message ?? '登录失败',
        code: response.code,
      );
    }

    final session = _mapper.toSession(response);
    if (session.accessToken.isEmpty) {
      throw const ValidationException('登录失败，令牌为空', code: 'AUTH_EMPTY_TOKEN');
    }

    await _local.persistSession(session);
    return session;
  }

  @override
  Future<void> register({
    required String phone,
    required String password,
    String? nickname,
  }) {
    return _remote.register(
      RegisterRequestDto(
        phone: phone,
        password: password,
        passwordConfirmation: password,
        realnameVerified: true,
        nickname: nickname,
      ),
    );
  }

  @override
  Future<void> logout() {
    return _local.clearSession();
  }
}
