class HomeFeedDto {
  const HomeFeedDto({
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

  factory HomeFeedDto.fromJson(Map<String, dynamic> json) {
    final mediaRaw = (json['media'] as List<dynamic>? ?? const []);
    final tagsRaw = (json['tags'] as List<dynamic>? ?? const []);
    return HomeFeedDto(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      author: (json['author'] ?? '').toString(),
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      body: (json['body'] ?? '').toString().isEmpty ? null : (json['body'] ?? '').toString(),
      media: mediaRaw
          .map((e) {
            if (e is Map<String, dynamic>) {
              return (e['url'] ?? '').toString();
            }
            return e.toString();
          })
          .where((e) => e.isNotEmpty)
          .toList(),
      tags: tagsRaw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList(),
    );
  }
}
