import 'package:flutter_elitesync/features/verification/domain/entities/verification_state_entity.dart';

abstract class VerificationRepository {
  Future<VerificationStateEntity> getStatus();
  Future<void> submit({required String realName, required String idNumber});
}
