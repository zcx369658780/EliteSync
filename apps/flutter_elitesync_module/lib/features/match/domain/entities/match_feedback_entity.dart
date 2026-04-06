class MatchFeedbackEntity {
  const MatchFeedbackEntity({
    required this.createdAt,
    required this.matchHeadline,
    required this.matchScore,
    required this.matchTags,
    required this.overallFeedback,
    required this.explanationFeedback,
    required this.icebreakerFeedback,
    required this.nextWeekIntention,
    required this.note,
  });

  final DateTime createdAt;
  final String matchHeadline;
  final int matchScore;
  final List<String> matchTags;
  final String overallFeedback;
  final String explanationFeedback;
  final String icebreakerFeedback;
  final String nextWeekIntention;
  final String note;

  Map<String, dynamic> toJson() => {
        'created_at': createdAt.toIso8601String(),
        'match_headline': matchHeadline,
        'match_score': matchScore,
        'match_tags': matchTags,
        'overall_feedback': overallFeedback,
        'explanation_feedback': explanationFeedback,
        'icebreaker_feedback': icebreakerFeedback,
        'next_week_intention': nextWeekIntention,
        'note': note,
      };

  factory MatchFeedbackEntity.fromJson(Map<String, dynamic> json) {
    final tags = (json['match_tags'] as List<dynamic>? ?? const [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList();
    return MatchFeedbackEntity(
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString())?.toLocal() ?? DateTime.now().toLocal(),
      matchHeadline: (json['match_headline'] ?? '').toString(),
      matchScore: (json['match_score'] as num?)?.toInt() ?? 0,
      matchTags: tags,
      overallFeedback: (json['overall_feedback'] ?? '').toString(),
      explanationFeedback: (json['explanation_feedback'] ?? '').toString(),
      icebreakerFeedback: (json['icebreaker_feedback'] ?? '').toString(),
      nextWeekIntention: (json['next_week_intention'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }
}
