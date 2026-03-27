import 'package:flutter_elitesync/features/profile/domain/entities/profile_summary_entity.dart';

class ProfileUiState {
  const ProfileUiState({this.summary, this.error});
  final ProfileSummaryEntity? summary;
  final String? error;
}
