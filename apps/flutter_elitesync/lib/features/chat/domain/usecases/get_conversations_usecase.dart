import 'package:flutter_elitesync/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync/features/chat/domain/repository/chat_repository.dart';

class GetConversationsUseCase {
  const GetConversationsUseCase(this.repository);
  final ChatRepository repository;
  Future<List<ConversationEntity>> call() => repository.getConversations();
}
