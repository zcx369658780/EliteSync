import 'package:flutter_elitesync/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync/features/chat/domain/entities/message_entity.dart';

class ChatMapper {
  const ChatMapper();
  ConversationEntity conversation(ConversationDto dto) => ConversationEntity(
        id: dto.id,
        name: dto.name,
        lastMessage: dto.lastMessage,
        lastTime: dto.lastTime,
        unread: dto.unread,
      );
  MessageEntity message(MessageDto dto) => MessageEntity(id: dto.id, mine: dto.mine, text: dto.text, time: dto.time);
}
