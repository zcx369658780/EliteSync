class SendMessageRequestDto {
  const SendMessageRequestDto({required this.text});
  final String text;

  Map<String, dynamic> toJson() => {'text': text};
}
