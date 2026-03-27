import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';

class ChatRoomUiState {
  const ChatRoomUiState({this.messages = const [], this.sending = false, this.error});

  final List<MessageEntity> messages;
  final bool sending;
  final String? error;
}
