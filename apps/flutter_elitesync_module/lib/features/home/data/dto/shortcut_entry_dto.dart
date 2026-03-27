class ShortcutEntryDto {
  const ShortcutEntryDto({
    required this.key,
    required this.title,
    this.action,
    this.target,
  });
  final String key;
  final String title;
  final String? action;
  final String? target;

  factory ShortcutEntryDto.fromJson(Map<String, dynamic> json) {
    return ShortcutEntryDto(
      key: (json['key'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      action: (json['action'] ?? '').toString().isEmpty
          ? null
          : (json['action'] ?? '').toString(),
      target: (json['target'] ?? '').toString().isEmpty
          ? null
          : (json['target'] ?? '').toString(),
    );
  }
}
