import 'package:flutter_elitesync/features/profile/data/dto/profile_detail_dto.dart';
import 'package:flutter_elitesync/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync/features/profile/domain/entities/profile_summary_entity.dart';

class ProfileMapper {
  const ProfileMapper();

  ProfileSummaryEntity toSummary(ProfileSummaryDto dto) => ProfileSummaryEntity(
        nickname: dto.nickname,
        city: dto.city,
        verified: dto.verified,
        completion: dto.completion,
        tags: dto.tags,
      );

  ProfileDetailEntity toDetail(ProfileDetailDto dto) => ProfileDetailEntity(
        nickname: dto.nickname,
        gender: dto.gender,
        birthday: dto.birthday,
        city: dto.city,
        target: dto.target,
      );
}
