import 'package:flutter_elitesync_module/features/questionnaire/data/dto/question_item_dto.dart';

class QuestionnaireBundleDto {
  const QuestionnaireBundleDto({
    required this.version,
    required this.total,
    required this.estimatedMinutes,
    required this.questions,
  });

  final String version;
  final int total;
  final int estimatedMinutes;
  final List<QuestionItemDto> questions;

  factory QuestionnaireBundleDto.fromJson(Map<String, dynamic> json) {
    final meta = (json['meta'] as Map<String, dynamic>?) ?? const {};
    final rawQuestions = (json['questions'] as List?) ?? const [];
    return QuestionnaireBundleDto(
      version: (meta['version'] as String?) ?? 'q_v1',
      total: (meta['total'] as num?)?.toInt() ?? rawQuestions.length,
      estimatedMinutes: (meta['estimated_minutes'] as num?)?.toInt() ?? 5,
      questions: rawQuestions
          .whereType<Map<String, dynamic>>()
          .map(QuestionItemDto.fromJson)
          .toList(),
    );
  }
}
