import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_bundle_dto.dart';

void main() {
  test('questionnaire bundle dto parses versioned meta', () {
    final dto = QuestionnaireBundleDto.fromJson({
      'meta': {
        'version': 'q_v2',
        'bank_version': 'qb_v1',
        'attempt_version': 'qa_v1',
        'label': '非官方人格四维问卷',
        'non_official_notice': '仅用于产品内人格倾向参考，不代表官方 MBTI。',
        'estimated_minutes': 6,
        'total': 20,
      },
      'questions': [
        {
          'id': 1,
          'content': '面对冲突时，你更倾向？',
          'options': ['先冷静再沟通'],
          'question_version': 2,
        },
      ],
    });

    expect(dto.version, 'q_v2');
    expect(dto.bankVersion, 'qb_v1');
    expect(dto.attemptVersion, 'qa_v1');
    expect(dto.label, '非官方人格四维问卷');
    expect(dto.nonOfficialNotice, '仅用于产品内人格倾向参考，不代表官方 MBTI。');
    expect(dto.total, 20);
    expect(dto.estimatedMinutes, 6);
    expect(dto.questions, hasLength(1));
    expect(dto.questions.first.version, 2);
  });
}
