import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync/features/match/data/mapper/match_mapper.dart';
import 'package:flutter_elitesync/features/match/data/dto/match_result_dto.dart';

void main() {
  test('MatchMapper maps dto to entity', () {
    const mapper = MatchMapper();
    final dto = MatchResultDto(
      status: 'matched',
      headline: 'test',
      score: 88,
      tags: ['同城'],
      highlights: [
        {'title': '沟通', 'value': 80, 'desc': '良好'},
      ],
    );

    final entity = mapper.result(dto);
    expect(entity.score, 88);
    expect(entity.highlights.first.title, '沟通');
  });
}
