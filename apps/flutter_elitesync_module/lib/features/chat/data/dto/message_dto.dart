import 'package:flutter_elitesync_module/features/chat/data/dto/message_attachment_dto.dart';

class MessageDto {
  const MessageDto({
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
  final List<MessageAttachmentDto> attachments;

  bool get hasAttachments => attachments.isNotEmpty;
  bool get hasImageAttachment =>
      attachments.any((attachment) => attachment.isImage);
  bool get hasVideoAttachment =>
      attachments.any((attachment) => attachment.isVideo);

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
    id: (json['id'] ?? '').toString(),
    mine: (json['mine'] as bool?) ?? false,
    text: (json['text'] ?? json['content'] ?? '').toString(),
    time: (json['time'] ?? '').toString(),
    attachments: (json['attachments'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(MessageAttachmentDto.fromJson)
        .toList(),
  );
}
