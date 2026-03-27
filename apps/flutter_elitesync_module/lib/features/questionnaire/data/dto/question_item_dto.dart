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
    return QuestionItemDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: (json['title'] as String?) ?? '',
      options: ((json['options'] as List?) ?? const [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}
