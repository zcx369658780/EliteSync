class MatchDetailEntity {
  const MatchDetailEntity({required this.reasons, required this.weights});

  final List<String> reasons;
  final Map<String, int> weights;
}
