import 'package:flutter_elitesync_module/features/profile/data/datasource/profile_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/update_profile_request_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/birth_place_suggestion_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl({required this.remote, required this.mapper});

  final ProfileRemoteDataSource remote;
  final ProfileMapper mapper;

  @override
  Future<ProfileDetailEntity> getDetail() async => mapper.toDetail(await remote.getDetail());

  @override
  Future<ProfileSummaryEntity> getSummary() async => mapper.toSummary(await remote.getSummary());

  @override
  Future<Map<String, dynamic>> update(ProfileDetailEntity detail) {
    return remote.update(
      UpdateProfileRequestDto(
        nickname: detail.nickname,
        gender: detail.gender,
        birthday: detail.birthday,
        birthTime: detail.birthTime,
        city: detail.city,
        target: detail.target,
        birthPlace: detail.birthPlace,
        birthLat: detail.birthLat,
        birthLng: detail.birthLng,
      ),
    );
  }

  @override
  Future<List<BirthPlaceSuggestionEntity>> searchBirthPlaces({
    required String query,
    String region = '全国',
  }) {
    return remote.searchBirthPlaces(query: query, region: region);
  }
}
