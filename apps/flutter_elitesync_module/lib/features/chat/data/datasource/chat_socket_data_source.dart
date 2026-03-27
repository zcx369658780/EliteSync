import 'dart:async';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';

class ChatSocketDataSource {
  Stream<MessageDto> observe(String conversationId) {
    return const Stream.empty();
  }
}
