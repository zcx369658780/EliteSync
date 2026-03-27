class QuestionItem {
  const QuestionItem({
    required this.id,
    required this.title,
    required this.options,
  });

  final int id;
  final String title;
  final List<String> options;
}
