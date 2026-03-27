class PageCursor {
  const PageCursor({this.next, this.prev, this.hasMore = false});

  final String? next;
  final String? prev;
  final bool hasMore;

  factory PageCursor.fromJson(Map<String, dynamic> json) {
    return PageCursor(
      next: json['next'] as String?,
      prev: json['prev'] as String?,
      hasMore: (json['has_more'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'next': next, 'prev': prev, 'has_more': hasMore};
  }
}
