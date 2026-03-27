class ProfileSummaryEntity {
  const ProfileSummaryEntity({
    required this.nickname,
    required this.city,
    required this.verified,
    required this.completion,
    required this.tags,
  });

  final String nickname;
  final String city;
  final bool verified;
  final double completion;
  final List<String> tags;
}
