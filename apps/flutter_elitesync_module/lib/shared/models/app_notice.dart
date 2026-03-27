class AppNotice {
  const AppNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.type = 'info',
  });

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String type;

  factory AppNotice.fromJson(Map<String, dynamic> json) {
    return AppNotice(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      content: (json['content'] as String?) ?? '',
      createdAt:
          DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      type: (json['type'] as String?) ?? 'info',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'type': type,
    };
  }
}
