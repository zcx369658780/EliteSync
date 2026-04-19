import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/questionnaire/data/dto/questionnaire_attempt_dto.dart';

void main() {
  test('questionnaire attempt dto parses history payload', () {
    final dto = QuestionnaireAttemptDto.fromJson({
      'id': 101,
      'questionnaire_version': 'q_v2',
      'bank_version': 'qb_v1',
      'attempt_version': 'qa_v1',
      'answers_count': 2,
      'total_count': 20,
      'result_label': '倾向：attachment_security + communication_clarity',
      'result_highlights': [
        'attachment_security 56',
        'communication_clarity 63',
      ],
      'profile_complete': false,
      'completed_at': '2026-04-18T09:10:00+08:00',
    });

    expect(dto.id, 101);
    expect(dto.questionnaireVersion, 'q_v2');
    expect(dto.bankVersion, 'qb_v1');
    expect(dto.attemptVersion, 'qa_v1');
    expect(dto.answersCount, 2);
    expect(dto.totalCount, 20);
    expect(dto.resultLabel, contains('attachment_security'));
    expect(dto.resultHighlights, hasLength(2));
    expect(dto.profileComplete, isFalse);
    expect(dto.completedAt, isNotEmpty);
  });
}
