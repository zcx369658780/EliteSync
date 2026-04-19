class QuestionnaireSubmissionResult {
  const QuestionnaireSubmissionResult({
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
}
