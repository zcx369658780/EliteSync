import 'package:flutter_elitesync/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync/features/profile/domain/repository/profile_repository.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this.repository);
  final ProfileRepository repository;
  Future<void> call(ProfileDetailEntity detail) => repository.update(detail);
}
