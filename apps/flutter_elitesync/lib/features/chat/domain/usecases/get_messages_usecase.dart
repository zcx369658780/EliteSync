import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync/features/chat/domain/repository/chat_repository.dart';

class GetMessagesUseCase {
  const GetMessagesUseCase(this.repository);
  final ChatRepository repository;
  Future<List<MessageEntity>> call(String conversationId) => repository.getMessages(conversationId);
}
