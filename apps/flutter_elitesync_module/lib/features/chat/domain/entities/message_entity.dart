import 'package:flutter_elitesync_module/features/chat/domain/entities/message_attachment_entity.dart';

class MessageEntity {
  const MessageEntity({
    required this.id,
    required this.mine,
    required this.text,
    required this.time,
    required this.attachments,
  });
  final String id;
  final bool mine;
  final String text;
  final String time;
  final List<MessageAttachmentEntity> attachments;

  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasImageAttachment =>
      attachments.any((attachment) => attachment.isImage);
  bool get hasVideoAttachment =>
      attachments.any((attachment) => attachment.isVideo);
}
