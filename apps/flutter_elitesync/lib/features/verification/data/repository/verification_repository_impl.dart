import 'package:flutter_elitesync/features/verification/data/datasource/verification_remote_data_source.dart';
import 'package:flutter_elitesync/features/verification/data/dto/submit_verification_request_dto.dart';
import 'package:flutter_elitesync/features/verification/data/mapper/verification_mapper.dart';
import 'package:flutter_elitesync/features/verification/domain/entities/verification_state_entity.dart';
import 'package:flutter_elitesync/features/verification/domain/repository/verification_repository.dart';

class VerificationRepositoryImpl implements VerificationRepository {
  const VerificationRepositoryImpl({
    required this.remote,
    required this.mapper,
  });

  final VerificationRemoteDataSource remote;
  final VerificationMapper mapper;

  @override
  Future<VerificationStateEntity> getStatus() async {
    final dto = await remote.fetchStatus();
    return mapper.toEntity(dto);
  }

  @override
  Future<void> submit({required String realName, required String idNumber}) {
    return remote.submit(
      SubmitVerificationRequestDto(realName: realName, idNumber: idNumber),
    );
  }
}
