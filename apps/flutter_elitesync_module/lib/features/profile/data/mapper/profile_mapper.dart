import 'package:flutter_elitesync_module/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';

class ProfileMapper {
  const ProfileMapper();

  ProfileSummaryEntity toSummary(ProfileSummaryDto dto) => ProfileSummaryEntity(
        nickname: dto.nickname,
        birthday: dto.birthday,
        birthTime: dto.birthTime,
        birthPlace: dto.birthPlace,
        city: dto.city,
        target: dto.target,
        verified: dto.verified,
        completion: dto.completion,
        tags: dto.tags,
      );

  ProfileDetailEntity toDetail(ProfileDetailDto dto) => ProfileDetailEntity(
        nickname: dto.nickname,
        gender: dto.gender,
        birthday: dto.birthday,
        birthTime: dto.birthTime,
        city: dto.city,
        target: dto.target,
        birthPlace: dto.birthPlace,
        birthLat: dto.birthLat,
        birthLng: dto.birthLng,
      );
}
