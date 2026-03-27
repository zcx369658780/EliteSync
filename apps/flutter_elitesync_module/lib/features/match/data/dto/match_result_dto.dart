class MatchResultDto {
  const MatchResultDto({required this.status, required this.headline, required this.score, required this.tags, required this.highlights});
  final String status;
  final String headline;
  final int score;
  final List<String> tags;
  final List<Map<String, dynamic>> highlights;

  factory MatchResultDto.fromJson(Map<String, dynamic> json) {
    return MatchResultDto(
      status: (json['status'] ?? '').toString(),
      headline: (json['headline'] ?? '').toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      highlights: (json['highlights'] as List<dynamic>? ?? const []).whereType<Map<String, dynamic>>().toList(),
    );
  }
}
