class ConversationDto {
  const ConversationDto({required this.id, required this.name, required this.lastMessage, required this.lastTime, required this.unread});
  final String id;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unread;

  factory ConversationDto.fromJson(Map<String, dynamic> json) => ConversationDto(
        id: (json['id'] ?? '').toString(),
        name: (json['name'] ?? '').toString(),
        lastMessage: (json['last_message'] ?? '').toString(),
        lastTime: (json['last_time'] ?? '').toString(),
        unread: (json['unread'] as num?)?.toInt() ?? 0,
      );
}
