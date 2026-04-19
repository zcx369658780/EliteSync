class QuestionItem {
  const QuestionItem({
    required this.id,
    required this.title,
    required this.options,
    required this.version,
  });

  final int id;
  final String title;
  final List<String> options;
  final int version;
}
