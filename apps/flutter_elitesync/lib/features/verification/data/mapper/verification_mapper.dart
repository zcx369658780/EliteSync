import 'package:flutter_elitesync/features/verification/data/dto/verification_status_dto.dart';
import 'package:flutter_elitesync/features/verification/domain/entities/verification_state_entity.dart';

class VerificationMapper {
  const VerificationMapper();

  VerificationStateEntity toEntity(VerificationStatusDto dto) {
    return VerificationStateEntity(
      status: dto.status,
      title: dto.title,
      description: dto.description,
    );
  }
}
