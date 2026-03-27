import 'package:flutter_elitesync/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Future<List<ConversationEntity>> getConversations();
  Future<List<MessageEntity>> getMessages(String conversationId);
  Future<void> sendMessage(String conversationId, String text);
  Stream<MessageEntity> observeMessages(String conversationId);
}
