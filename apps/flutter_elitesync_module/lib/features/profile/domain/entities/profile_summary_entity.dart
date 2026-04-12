class ProfileSummaryEntity {
  const ProfileSummaryEntity({
    required this.nickname,
    required this.birthday,
    required this.birthTime,
    required this.birthPlace,
    this.birthLat,
    this.birthLng,
    required this.city,
    required this.target,
    required this.verified,
    required this.moderationStatus,
    required this.moderationNote,
    required this.completion,
    required this.tags,
  });

  final String nickname;
  final String birthday;
  final String birthTime;
  final String? birthPlace;
  final double? birthLat;
  final double? birthLng;
  final String city;
  final String target;
  final bool verified;
  final String moderationStatus;
  final String? moderationNote;
  final double completion;
  final List<String> tags;
}
