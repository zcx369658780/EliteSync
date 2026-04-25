class NotificationItemEntity {
  const NotificationItemEntity({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.payload,
    required this.routeName,
    required this.routeArgs,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.expiresAt,
  });

  final int id;
  final String kind;
  final String title;
  final String body;
  final Map<String, dynamic> payload;
  final String routeName;
  final Map<String, dynamic> routeArgs;
  final bool isRead;
  final String createdAt;
  final String? readAt;
  final String? expiresAt;

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

  factory NotificationItemEntity.fromJson(Map<String, dynamic> json) {
    final payload = _mapFromJson(json['payload']);
    final routeArgs = _mapFromJson(payload['route_args']);
    return NotificationItemEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      kind: (json['kind'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: (json['body'] ?? '').toString(),
      payload: payload,
      routeName: (json['route_name'] ?? payload['route_name'] ?? '').toString(),
      routeArgs: routeArgs,
      isRead: (json['is_read'] as bool?) ?? json['read_at'] != null,
      createdAt: (json['created_at'] ?? '').toString(),
      readAt: json['read_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
    );
  }
}
