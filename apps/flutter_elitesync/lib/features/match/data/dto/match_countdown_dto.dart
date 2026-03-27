class MatchCountdownDto {
  const MatchCountdownDto({required this.status, required this.revealAt, required this.hint});
  final String status;
  final String revealAt;
  final String hint;
  factory MatchCountdownDto.fromJson(Map<String, dynamic> json) => MatchCountdownDto(
        status: (json['status'] ?? '').toString(),
        revealAt: (json['reveal_at'] ?? '').toString(),
        hint: (json['hint'] ?? '').toString(),
      );
}
