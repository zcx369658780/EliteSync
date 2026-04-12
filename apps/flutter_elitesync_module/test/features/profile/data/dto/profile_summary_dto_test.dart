import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/profile/data/dto/profile_summary_dto.dart';
import 'package:flutter_elitesync_module/features/profile/data/mapper/profile_mapper.dart';

void main() {
  test('profile summary dto maps birth place coordinates', () {
    const json = <String, dynamic>{
      'nickname': 'Mia',
      'birthday': '1998-04-20',
      'birth_time': '09:30',
      'birth_place': '武汉',
      'birth_lat': 30.5928,
      'birth_lng': 114.3055,
      'city': '武汉',
      'target': 'dating',
      'verified': true,
      'moderation_status': 'normal',
      'completion': 0.9,
      'tags': ['生日已保存'],
    };

    final dto = ProfileSummaryDto.fromJson(json);
    final summary = const ProfileMapper().toSummary(dto);

    expect(dto.birthLat, 30.5928);
    expect(dto.birthLng, 114.3055);
    expect(summary.birthLat, 30.5928);
    expect(summary.birthLng, 114.3055);
    expect(summary.birthPlace, '武汉');
  });
}
