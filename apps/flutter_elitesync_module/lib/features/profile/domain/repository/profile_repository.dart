import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/birth_place_suggestion_entity.dart';

abstract class ProfileRepository {
  Future<ProfileSummaryEntity> getSummary();
  Future<ProfileDetailEntity> getDetail();
  Future<Map<String, dynamic>> update(ProfileDetailEntity detail);
  Future<List<BirthPlaceSuggestionEntity>> searchBirthPlaces({
    required String query,
    String region,
  });
}
