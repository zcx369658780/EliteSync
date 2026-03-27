import 'package:flutter_elitesync/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync/features/profile/domain/repository/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this.repository);
  final ProfileRepository repository;
  Future<ProfileSummaryEntity> call() => repository.getSummary();
}
