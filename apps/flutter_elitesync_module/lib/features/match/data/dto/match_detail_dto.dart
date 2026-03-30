class MatchDetailDto {
  const MatchDetailDto({
    required this.reasons,
    required this.weights,
    this.moduleScores = const {},
    this.moduleInsights = const [],
    this.moduleExplanations = const [],
    this.explanationBlocks = const [],
    this.compatibilitySections = const {},
    this.reasonGlossary = const {},
    this.evidenceStrengthSummary = const {},
  });
  final List<String> reasons;
  final Map<String, int> weights;
  final Map<String, int> moduleScores;
  final List<String> moduleInsights;
  final List<Map<String, dynamic>> moduleExplanations;
  final List<Map<String, dynamic>> explanationBlocks;
  final Map<String, List<Map<String, dynamic>>> compatibilitySections;
  final Map<String, String> reasonGlossary;
  final Map<String, dynamic> evidenceStrengthSummary;

  factory MatchDetailDto.fromJson(Map<String, dynamic> json) => MatchDetailDto(
    reasons: _asList(json['reasons'])
        .map((e) => e.toString())
        .toList(),
    weights: _asMap(json['weights']).map(
      (k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0),
    ),
    moduleScores: _asMap(json['module_scores'])
        .map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
    moduleInsights: _asList(json['module_insights'])
        .map((e) => e.toString())
        .toList(),
    moduleExplanations: _toListOfMap(json['module_explanations']),
    explanationBlocks: _toListOfMap(json['explanation_blocks']),
    compatibilitySections: _normalizeCompatibilitySections(
      json['compatibility_sections'],
    ),
    reasonGlossary: _asMap(json['reason_glossary']).map(
      (k, v) => MapEntry(k.toString(), v.toString()),
    ),
    evidenceStrengthSummary: _normalizeEvidenceStrengthSummary(
      json['evidence_strength_summary'],
    ),
  );
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map(
      (key, val) => MapEntry(key.toString(), val),
    );
  }
  return <String, dynamic>{};
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return List<dynamic>.from(value);
  return const <dynamic>[];
}

List<Map<String, dynamic>> _toListOfMap(dynamic value) {
  return _asList(value).map(_asMap).where((e) => e.isNotEmpty).toList();
}

Map<String, List<Map<String, dynamic>>> _normalizeCompatibilitySections(
  dynamic raw,
) {
  final map = _asMap(raw);
  if (map.isNotEmpty) {
    return map.map(
      (k, v) => MapEntry(k.toString(), _toListOfMap(v)),
    );
  }

  // Backward/abnormal payload fallback: if server returns a list directly.
  final rows = _toListOfMap(raw);
  if (rows.isNotEmpty) {
    return <String, List<Map<String, dynamic>>>{
      'synastry': rows,
    };
  }

  return const <String, List<Map<String, dynamic>>>{};
}

Map<String, dynamic> _normalizeEvidenceStrengthSummary(dynamic raw) {
  final map = _asMap(raw);
  if (map.isNotEmpty) return map;

  final rows = _toListOfMap(raw);
  if (rows.isNotEmpty) {
    return <String, dynamic>{'items': rows};
  }

  return const <String, dynamic>{};
}
