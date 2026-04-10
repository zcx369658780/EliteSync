class MatchResultDto {
  const MatchResultDto({
    required this.status,
    required this.headline,
    required this.score,
    required this.tags,
    required this.highlights,
    this.matchId,
    this.partnerId,
    this.partnerNickname,
  });
  final String status;
  final String headline;
  final int score;
  final List<String> tags;
  final List<Map<String, dynamic>> highlights;
  final int? matchId;
  final int? partnerId;
  final String? partnerNickname;

  factory MatchResultDto.fromJson(Map<String, dynamic> json) {
    return MatchResultDto(
      status: (json['status'] ?? '').toString(),
      headline: (json['headline'] ?? '').toString(),
      score: (json['score'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      highlights: (json['highlights'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .toList(),
      matchId: (json['match_id'] as num?)?.toInt(),
      partnerId: (json['partner_id'] as num?)?.toInt(),
      partnerNickname:
          (json['partner_nickname'] ?? '').toString().trim().isEmpty
          ? null
          : (json['partner_nickname'] ?? '').toString().trim(),
    );
  }
}
