import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/question_item.dart';

class QuestionnaireBundle {
  const QuestionnaireBundle({
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
  final List<QuestionItem> questions;
}
