import 'package:flutter_elitesync_module/features/verification/domain/entities/verification_state_entity.dart';
import 'package:flutter_elitesync_module/features/verification/domain/repository/verification_repository.dart';

class GetVerificationStatusUseCase {
  const GetVerificationStatusUseCase(this.repository);

  final VerificationRepository repository;

  Future<VerificationStateEntity> call() => repository.getStatus();
}
