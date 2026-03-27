class ConversationEntity {
  const ConversationEntity({required this.id, required this.name, required this.lastMessage, required this.lastTime, required this.unread});
  final String id;
  final String name;
  final String lastMessage;
  final String lastTime;
  final int unread;
}
