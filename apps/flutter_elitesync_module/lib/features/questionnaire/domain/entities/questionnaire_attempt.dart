class QuestionnaireAttempt {
  const QuestionnaireAttempt({
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
  final DateTime? completedAt;
}
