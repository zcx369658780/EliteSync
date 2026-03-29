class MatchDetailDto {
  const MatchDetailDto({
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

  factory MatchDetailDto.fromJson(Map<String, dynamic> json) => MatchDetailDto(
        reasons: (json['reasons'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        weights: (json['weights'] as Map<String, dynamic>? ?? const {}).map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
        moduleScores: (json['module_scores'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
        ),
        moduleInsights: (json['module_insights'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        moduleExplanations: (json['module_explanations'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList(),
        reasonGlossary: (json['reason_glossary'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
        evidenceStrengthSummary:
            (json['evidence_strength_summary'] as Map<String, dynamic>? ?? const {}),
      );
}
