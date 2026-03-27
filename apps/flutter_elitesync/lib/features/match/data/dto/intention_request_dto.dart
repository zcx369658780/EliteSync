class IntentionRequestDto {
  const IntentionRequestDto({required this.action});
  final String action;

  Map<String, dynamic> toJson() => {'action': action};
}
