class SendMessageRequestDto {
  const SendMessageRequestDto({
    required this.receiverId,
    required this.content,
  });
  final int receiverId;
  final String content;

  Map<String, dynamic> toJson() => {
    'receiver_id': receiverId,
    'content': content,
  };
}
