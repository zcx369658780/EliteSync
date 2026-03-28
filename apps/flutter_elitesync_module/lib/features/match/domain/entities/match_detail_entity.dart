class MatchDetailEntity {
  const MatchDetailEntity({
    required this.reasons,
    required this.weights,
    this.moduleScores = const {},
    this.moduleInsights = const [],
    this.reasonGlossary = const {},
  });

  final List<String> reasons;
  final Map<String, int> weights;
  final Map<String, int> moduleScores;
  final List<String> moduleInsights;
  final Map<String, String> reasonGlossary;
}
