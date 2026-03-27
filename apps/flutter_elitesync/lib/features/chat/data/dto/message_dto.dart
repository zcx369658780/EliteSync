class MessageDto {
  const MessageDto({required this.id, required this.mine, required this.text, required this.time});
  final String id;
  final bool mine;
  final String text;
  final String time;

  factory MessageDto.fromJson(Map<String, dynamic> json) => MessageDto(
        id: (json['id'] ?? '').toString(),
        mine: (json['mine'] as bool?) ?? false,
        text: (json['text'] ?? '').toString(),
        time: (json['time'] ?? '').toString(),
      );
}
