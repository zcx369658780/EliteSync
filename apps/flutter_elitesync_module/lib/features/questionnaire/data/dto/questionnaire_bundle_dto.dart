import 'package:flutter_elitesync_module/features/questionnaire/data/dto/question_item_dto.dart';

class QuestionnaireBundleDto {
  const QuestionnaireBundleDto({
    required this.version,
    required this.bankVersion,
    required this.attemptVersion,
    required this.label,
    required this.nonOfficialNotice,
    required this.total,
    required this.estimatedMinutes,
    required this.questions,
  });

  final String version;
  final String bankVersion;
  final String attemptVersion;
  final String label;
  final String nonOfficialNotice;
  final int total;
  final int estimatedMinutes;
  final List<QuestionItemDto> questions;

  factory QuestionnaireBundleDto.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};
    final rawQuestions =
        (json['questions'] as List?) ?? (json['items'] as List?) ?? const [];
    final fallbackTotal =
        (json['total'] as num?)?.toInt() ??
        (json['required'] as num?)?.toInt() ??
        rawQuestions.length;
    return QuestionnaireBundleDto(
      version:
          (meta['version'] as String?) ??
          (json['version'] as String?) ??
          'q_v2',
      bankVersion:
          (meta['bank_version'] as String?) ??
          (json['bank_version'] as String?) ??
          'qb_v1',
      attemptVersion:
          (meta['attempt_version'] as String?) ??
          (json['attempt_version'] as String?) ??
          'qa_v1',
      label:
          (meta['label'] as String?) ??
          (json['label'] as String?) ??
          '非官方人格四维问卷',
      nonOfficialNotice:
          (meta['non_official_notice'] as String?) ??
          (json['non_official_notice'] as String?) ??
          '仅用于产品内人格倾向参考，不代表官方 MBTI。',
      total: (meta['total'] as num?)?.toInt() ?? fallbackTotal,
      estimatedMinutes: (meta['estimated_minutes'] as num?)?.toInt() ?? 6,
      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(QuestionItemDto.fromJson)
          .toList(),
    );
  }
}
