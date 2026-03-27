import 'package:flutter_elitesync/features/verification/domain/repository/verification_repository.dart';

class SubmitVerificationUseCase {
  const SubmitVerificationUseCase(this.repository);

  final VerificationRepository repository;

  Future<void> call({required String realName, required String idNumber}) {
    return repository.submit(realName: realName, idNumber: idNumber);
  }
}
