class QuestionnaireProfileSnapshot {
  const QuestionnaireProfileSnapshot({
    required this.questionnaireVersion,
    required this.bankVersion,
    required this.attemptVersion,
    required this.label,
    required this.highlights,
    required this.complete,
    this.updatedAt,
  });

  final String questionnaireVersion;
  final String bankVersion;
  final String attemptVersion;
  final String label;
  final List<String> highlights;
  final bool complete;
  final DateTime? updatedAt;

  factory QuestionnaireProfileSnapshot.fromJson(Map<String, dynamic> json) {
    final rawHighlights = json['highlights'];
    return QuestionnaireProfileSnapshot(
      questionnaireVersion: (json['questionnaire_version'] ?? 'q_v2')
          .toString(),
      bankVersion: (json['bank_version'] ?? 'qb_v1').toString(),
      attemptVersion: (json['attempt_version'] ?? 'qa_v1').toString(),
      label: (json['label'] ?? '倾向：待测').toString(),
      highlights: rawHighlights is List
          ? rawHighlights
                .map((e) => e.toString())
                .where((e) => e.trim().isNotEmpty)
                .toList()
          : const [],
      complete: (json['complete'] as bool?) ?? false,
      updatedAt: DateTime.tryParse((json['updated_at'] ?? '').toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'questionnaire_version': questionnaireVersion,
    'bank_version': bankVersion,
    'attempt_version': attemptVersion,
    'label': label,
    'highlights': highlights,
    'complete': complete,
    if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
  };

  String get versionLineage =>
      '$questionnaireVersion / $bankVersion / $attemptVersion';
}
