import 'package:flutter_elitesync_module/core/error/app_exception.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_request_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/login_response_dto.dart';
import 'package:flutter_elitesync_module/features/auth/data/dto/register_request_dto.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/auth_mock.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource({
    required ApiClient apiClient,
    required bool useMockAuth,
  }) : _apiClient = apiClient,
       _useMockAuth = useMockAuth;

  final ApiClient _apiClient;
  final bool _useMockAuth;

  Future<LoginResponseDto> login(LoginRequestDto request) async {
    if (_useMockAuth) {
      if (request.phone == '13800000022' && request.password == '1234567aa') {
        return LoginResponseDto.fromJson(AuthMock.loginHappy);
      }
      throw const ValidationException(
        '账号或密码错误',
        code: 'AUTH_INVALID_CREDENTIALS',
      );
    }

    final result = await _apiClient.post(
      '/api/v1/auth/login',
      body: request.toJson(),
    );
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return LoginResponseDto.fromJson(result.data);
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(failure.message, code: failure.code);
  }

  Future<void> register(RegisterRequestDto request) async {
    if (_useMockAuth) {
      if (request.phone == '13800000022') {
        throw const ValidationException('手机号已注册', code: 'AUTH_PHONE_EXISTS');
      }
      return;
    }

    final result = await _apiClient.post(
      '/api/v1/auth/register',
      body: request.toJson(),
    );
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      return;
    }

    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw ValidationException(failure.message, code: failure.code);
  }
}
