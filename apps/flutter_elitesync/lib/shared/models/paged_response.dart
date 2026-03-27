import 'package:flutter_elitesync/shared/models/page_cursor.dart';

class PagedResponse<T> {
  const PagedResponse({required this.items, required this.cursor, this.total});

  final List<T> items;
  final PageCursor cursor;
  final int? total;

  PagedResponse<T> copyWith({List<T>? items, PageCursor? cursor, int? total}) {
    return PagedResponse<T>(
      items: items ?? this.items,
      cursor: cursor ?? this.cursor,
      total: total ?? this.total,
    );
  }
}
