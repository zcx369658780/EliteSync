import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/core/error/error_mapper.dart';
import 'package:flutter_elitesync/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:flutter_elitesync/features/auth/data/mapper/auth_mapper.dart';
import 'package:flutter_elitesync/features/auth/data/repository/auth_repository_impl.dart';
import 'package:flutter_elitesync/features/auth/domain/repository/auth_repository.dart';
import 'package:flutter_elitesync/features/auth/domain/usecases/login_usecase.dart';
import 'package:flutter_elitesync/features/auth/domain/usecases/logout_usecase.dart';
import 'package:flutter_elitesync/features/auth/domain/usecases/register_usecase.dart';
import 'package:flutter_elitesync/shared/enums/auth_status.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';
import 'package:flutter_elitesync/shared/providers/session_provider.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSource(
    apiClient: apiClient,
    useMockAuth: env.useMockAuth,
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  final localStorage = ref.watch(localStorageProvider);
  return AuthLocalDataSource(
    secureStorage: secureStorage,
    localStorage: localStorage,
  );
});

final authMapperProvider = Provider<AuthMapper>((ref) {
  return const AuthMapper();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),
    local: ref.watch(authLocalDataSourceProvider),
    mapper: ref.watch(authMapperProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final authErrorMapperProvider = Provider<ErrorMapper>((ref) {
  return ref.watch(errorMapperProvider);
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final status = ref.watch(authStatusProvider);
  return status == AuthStatus.authenticated;
});
