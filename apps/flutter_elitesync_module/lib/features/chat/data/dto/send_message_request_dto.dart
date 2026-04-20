class SendMessageRequestDto {
  const SendMessageRequestDto({
    required this.receiverId,
    required this.content,
    this.attachmentIds = const [],
  });
  final int receiverId;
  final String content;
  final List<int> attachmentIds;

  Map<String, dynamic> toJson() => {
    'receiver_id': receiverId,
    'content': content,
    if (attachmentIds.isNotEmpty) 'attachment_ids': attachmentIds,
  };
}
