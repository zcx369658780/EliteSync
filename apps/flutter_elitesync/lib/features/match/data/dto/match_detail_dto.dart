class MatchDetailDto {
  const MatchDetailDto({required this.reasons, required this.weights});
  final List<String> reasons;
  final Map<String, int> weights;

  factory MatchDetailDto.fromJson(Map<String, dynamic> json) => MatchDetailDto(
        reasons: (json['reasons'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
        weights: (json['weights'] as Map<String, dynamic>? ?? const {}).map((k, v) => MapEntry(k, (v as num?)?.toInt() ?? 0)),
      );
}
