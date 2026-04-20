class QuestionnaireSubmissionResultDto {
  const QuestionnaireSubmissionResultDto({
    required this.questionnaireVersion,
    required this.bankVersion,
    required this.attemptVersion,
    required this.profileLabel,
    required this.profileHighlights,
    required this.profileComplete,
  });

  final String questionnaireVersion;
  final String bankVersion;
  final String attemptVersion;
  final String profileLabel;
  final List<String> profileHighlights;
  final bool profileComplete;

  factory QuestionnaireSubmissionResultDto.fromJson(Map<String, dynamic> json) {
    final profile = (json['profile'] as Map<String, dynamic>?) ?? const {};
    final summary = (profile['summary'] as Map<String, dynamic>?) ?? const {};
    return QuestionnaireSubmissionResultDto(
      questionnaireVersion:
          (json['questionnaire_version'] as String?) ?? 'q_v2',
      bankVersion: (json['bank_version'] as String?) ?? 'qb_v1',
      attemptVersion: (json['attempt_version'] as String?) ?? 'qa_v1',
      profileLabel: (summary['label'] as String?) ?? '倾向：待测',
      profileHighlights: ((summary['highlights'] as List?) ?? const [])
          .map((e) => e.toString())
          .where((e) => e.trim().isNotEmpty)
          .toList(),
      profileComplete: (profile['complete'] as bool?) ?? false,
    );
  }
}
