import 'dart:async';
import 'package:flutter_elitesync/features/chat/data/dto/message_dto.dart';

class ChatSocketDataSource {
  Stream<MessageDto> observe(String conversationId) {
    return const Stream.empty();
  }
}
