import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_author_entity.dart';

void main() {
  test('status author entity parses recent posts and author summary', () {
    final entity = StatusAuthorEntity.fromJson({
      'author': {
        'id': 19,
        'name': 'test1',
        'nickname': 'test1',
        'phone': '17094346566',
        'city': '南阳',
        'relationship_goal': 'dating',
        'public_mbti': 'INFJ',
        'public_personality': ['温和'],
        'is_synthetic': false,
        'is_square_visible': true,
      },
      'items': [
        {
          'id': 1,
          'title': '今夜动态',
          'body': '试一下动态流',
          'location_name': '南阳',
          'visibility': 'square',
          'likes_count': 2,
          'liked_by_viewer': false,
          'cover_media': {
            'id': 11,
            'public_url': 'https://example.com/dyn.png',
          },
          'created_at': '2026-04-19T08:00:00.000Z',
          'author': {
            'id': 19,
            'name': 'test1',
            'nickname': 'test1',
            'phone': '17094346566',
            'account_type': 'normal',
            'is_synthetic': false,
            'city': '南阳',
            'relationship_goal': 'dating',
          },
        },
      ],
      'total': 1,
    });

    expect(entity.displayName, 'test1');
    expect(entity.statusCount, 1);
    expect(entity.recentPosts, hasLength(1));
    expect(
      entity.recentPosts.first.coverMediaUrl,
      'https://example.com/dyn.png',
    );
    expect(entity.recentPosts.first.authorCity, '南阳');
  });
}
