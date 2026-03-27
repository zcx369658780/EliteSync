import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';

abstract class ProfileRepository {
  Future<ProfileSummaryEntity> getSummary();
  Future<ProfileDetailEntity> getDetail();
  Future<void> update(ProfileDetailEntity detail);
}
