class HomeFeedEntity {
  const HomeFeedEntity({
    required this.id,
    required this.title,
    required this.summary,
    required this.author,
    required this.likes,
    this.body,
    this.media = const [],
    this.tags = const [],
  });

  final String id;
  final String title;
  final String summary;
  final String author;
  final int likes;
  final String? body;
  final List<String> media;
  final List<String> tags;
}
