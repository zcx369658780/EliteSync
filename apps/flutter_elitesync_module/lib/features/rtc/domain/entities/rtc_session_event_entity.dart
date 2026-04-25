class RtcSessionEventEntity {
  const RtcSessionEventEntity({
    required this.id,
    required this.eventName,
    required this.userId,
    required this.payload,
    required this.createdAt,
  });

  final int id;
  final String eventName;
  final int? userId;
  final Map<String, dynamic> payload;
  final String createdAt;

  static Map<String, dynamic> _mapFromJson(dynamic value) {
    if (value is Map<String, dynamic>) {
      return Map<String, dynamic>.from(value);
    }
    if (value is Map) {
      return value.map(
        (key, dynamic item) => MapEntry(key.toString(), item),
      );
    }
    return const {};
  }

  factory RtcSessionEventEntity.fromJson(Map<String, dynamic> json) {
    return RtcSessionEventEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      eventName: (json['event_name'] ?? '').toString(),
      userId: (json['user_id'] as num?)?.toInt(),
      payload: _mapFromJson(json['payload']),
      createdAt: (json['created_at'] ?? '').toString(),
    );
  }
}
