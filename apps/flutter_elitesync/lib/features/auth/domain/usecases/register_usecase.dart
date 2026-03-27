import 'package:flutter_elitesync/features/auth/domain/repository/auth_repository.dart';

class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String phone,
    required String password,
    String? nickname,
  }) {
    return _repository.register(
      phone: phone,
      password: password,
      nickname: nickname,
    );
  }
}
