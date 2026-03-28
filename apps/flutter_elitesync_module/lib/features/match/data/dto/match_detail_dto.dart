class MatchDetailDto {
  const MatchDetailDto({
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

  factory MatchDetailDto.fromJson(Map<String, dynamic> json) => MatchDetailDto(
        reasons: (json['reasons'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        weights: (json['weights'] as Map<String, dynamic>? ?? const {}).map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
        moduleScores: (json['module_scores'] as Map<String, dynamic>? ?? const {}).map(
          (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
        ),
        moduleInsights: (json['module_insights'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        reasonGlossary: (json['reason_glossary'] as Map<String, dynamic>? ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
      );
}
