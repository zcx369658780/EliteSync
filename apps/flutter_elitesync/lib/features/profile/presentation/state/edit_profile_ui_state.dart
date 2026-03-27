import 'package:flutter_elitesync/features/profile/domain/entities/profile_detail_entity.dart';

class EditProfileUiState {
  const EditProfileUiState({this.detail, this.saving = false, this.error});
  final ProfileDetailEntity? detail;
  final bool saving;
  final String? error;
}
