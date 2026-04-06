class MatchCountdownEntity {
  const MatchCountdownEntity({
    required this.status,
    required this.revealAt,
    required this.hint,
  });

  final String status;
  final DateTime? revealAt;
  final String hint;
}
