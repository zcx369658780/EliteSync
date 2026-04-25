class RtcLiveKitJoinInfoEntity {
  const RtcLiveKitJoinInfoEntity({
    required this.enabled,
    required this.url,
    required this.token,
    required this.roomName,
    required this.identity,
    required this.participantName,
    required this.mode,
    required this.expiresAt,
  });

  final bool enabled;
  final String url;
  final String token;
  final String roomName;
  final String identity;
  final String participantName;
  final String mode;
  final String expiresAt;

  bool get isReady =>
      enabled && url.trim().isNotEmpty && token.trim().isNotEmpty;

  factory RtcLiveKitJoinInfoEntity.fromJson(Map<String, dynamic> json) {
    return RtcLiveKitJoinInfoEntity(
      enabled: (json['enabled'] as bool?) ?? false,
      url: (json['url'] ?? '').toString(),
      token: (json['token'] ?? '').toString(),
      roomName: (json['room_name'] ?? '').toString(),
      identity: (json['identity'] ?? '').toString(),
      participantName: (json['participant_name'] ?? '').toString(),
      mode: (json['mode'] ?? 'voice').toString(),
      expiresAt: (json['expires_at'] ?? '').toString(),
    );
  }
}

