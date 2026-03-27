import 'package:flutter_elitesync_module/features/chat/domain/entities/message_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';

class ObserveMessagesUseCase {
  const ObserveMessagesUseCase(this.repository);
  final ChatRepository repository;
  Stream<MessageEntity> call(String conversationId) => repository.observeMessages(conversationId);
}
