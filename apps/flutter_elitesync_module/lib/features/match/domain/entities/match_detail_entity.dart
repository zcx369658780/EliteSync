class MatchDetailEntity {
  const MatchDetailEntity({
    required this.reasons,
    required this.weights,
    this.moduleScores = const {},
    this.moduleInsights = const [],
    this.moduleExplanations = const [],
    this.reasonGlossary = const {},
    this.evidenceStrengthSummary = const {},
  });

  final List<String> reasons;
  final Map<String, int> weights;
  final Map<String, int> moduleScores;
  final List<String> moduleInsights;
  final List<Map<String, dynamic>> moduleExplanations;
  final Map<String, String> reasonGlossary;
  final Map<String, dynamic> evidenceStrengthSummary;
}
