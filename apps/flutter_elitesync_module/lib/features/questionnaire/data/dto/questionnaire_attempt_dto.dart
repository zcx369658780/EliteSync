class QuestionnaireAttemptDto {
  const QuestionnaireAttemptDto({
    required this.id,
    required this.questionnaireVersion,
    required this.bankVersion,
    required this.attemptVersion,
    required this.answersCount,
    required this.totalCount,
    required this.resultLabel,
    required this.resultHighlights,
    required this.profileComplete,
    required this.completedAt,
  });

  final int id;
  final String questionnaireVersion;
  final String bankVersion;
  final String attemptVersion;
  final int answersCount;
  final int totalCount;
  final String resultLabel;
  final List<String> resultHighlights;
  final bool profileComplete;
  final String completedAt;

  factory QuestionnaireAttemptDto.fromJson(Map<String, dynamic> json) {
    return QuestionnaireAttemptDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      questionnaireVersion:
          (json['questionnaire_version'] as String?) ?? 'q_v2',
      bankVersion: (json['bank_version'] as String?) ?? 'qb_v1',
      attemptVersion: (json['attempt_version'] as String?) ?? 'qa_v1',
      answersCount: (json['answers_count'] as num?)?.toInt() ?? 0,
      totalCount: (json['total_count'] as num?)?.toInt() ?? 0,
      resultLabel: (json['result_label'] as String?) ?? '倾向：待测',
      resultHighlights: ((json['result_highlights'] as List?) ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      profileComplete: (json['profile_complete'] as bool?) ?? false,
      completedAt: (json['completed_at'] as String?) ?? '',
    );
  }
}
