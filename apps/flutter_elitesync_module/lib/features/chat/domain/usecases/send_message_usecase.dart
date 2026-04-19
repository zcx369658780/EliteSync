import 'package:flutter_elitesync_module/features/chat/domain/repository/chat_repository.dart';

class SendMessageUseCase {
  const SendMessageUseCase(this.repository);
  final ChatRepository repository;
  Future<void> call(
    String conversationId,
    String text, {
    List<int> attachmentIds = const [],
  }) => repository.sendMessage(
    conversationId,
    text,
    attachmentIds: attachmentIds,
  );
}
