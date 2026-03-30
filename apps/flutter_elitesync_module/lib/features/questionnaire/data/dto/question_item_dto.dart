class QuestionItemDto {
  const QuestionItemDto({
    required this.id,
    required this.title,
    required this.options,
  });

  final int id;
  final String title;
  final List<String> options;

  factory QuestionItemDto.fromJson(Map<String, dynamic> json) {
    final optionItems = (json['option_items'] as List?) ?? const [];
    final optionsFromItems = optionItems
        .whereType<Map<String, dynamic>>()
        .map((item) {
          final label = item['label'];
          if (label is Map<String, dynamic>) {
            final zh = (label['zh'] as String?)?.trim() ?? '';
            if (zh.isNotEmpty) return zh;
            return (label['en'] as String?)?.trim() ?? '';
          }
          return '';
        })
        .where((v) => v.isNotEmpty)
        .toList();

    final options =
        optionsFromItems.isNotEmpty
            ? optionsFromItems
            : ((json['options'] as List?) ?? const [])
                .map((e) => e.toString())
                .where((v) => v.trim().isNotEmpty)
                .toList();

    return QuestionItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ??
          (json['content'] as String?) ??
          (json['question_text_zh'] as String?) ??
          (json['question_text_en'] as String?) ??
          '',
      options: options,
    );
  }
}
