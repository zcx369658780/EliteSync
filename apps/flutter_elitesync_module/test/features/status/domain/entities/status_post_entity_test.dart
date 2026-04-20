import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';

void main() {
  test('status post entity prefers synthetic truth for layer label', () {
    final entity = StatusPostEntity.fromJson({
      'id': 1,
      'title': '周末约会',
      'body': '一起去看展',
      'author': {
        'id': 2,
        'name': '晨雾',
        'phone': '13800000000',
        'role': 'user',
        'account_type': 'test',
        'is_synthetic': true,
      },
      'visibility': 'square',
      'can_delete': true,
      'created_at': '2026-04-10T08:00:00.000Z',
      'is_deleted': false,
    });

    expect(entity.authorLayerLabel, '合成账号');
    expect(entity.authorLayerBadge, '合成账号 · 广场可见');
  });

  test(
    'status post entity still labels non-synthetic test accounts correctly',
    () {
      final entity = StatusPostEntity.fromJson({
        'id': 3,
        'title': '日常分享',
        'body': '今天心情不错',
        'author': {
          'id': 4,
          'name': '阿沐',
          'phone': '13800000001',
          'role': 'user',
          'account_type': 'test',
          'is_synthetic': false,
        },
        'visibility': 'public',
        'can_delete': false,
        'created_at': '2026-04-10T08:00:00.000Z',
        'is_deleted': false,
      });

      expect(entity.authorLayerLabel, '测试账号');
      expect(entity.visibilityLabel, '公开');
    },
  );

  test('status post entity parses cover media and richer author metadata', () {
    final entity = StatusPostEntity.fromJson({
      'id': 5,
      'title': '今晚散步',
      'body': '带一张封面图试试',
      'author': {
        'id': 7,
        'name': '暮色',
        'nickname': '暮色',
        'phone': '13800000002',
        'role': 'user',
        'account_type': 'normal',
        'is_synthetic': false,
        'city': '南阳',
        'relationship_goal': 'dating',
        'public_mbti': 'INFP',
        'public_personality': ['温和', '慢热'],
      },
      'visibility': 'square',
      'can_delete': false,
      'likes_count': 8,
      'liked_by_viewer': true,
      'cover_media_asset_id': 42,
      'cover_media': {'id': 42, 'public_url': 'https://example.com/cover.png'},
      'created_at': '2026-04-10T08:00:00.000Z',
      'is_deleted': false,
    });

    expect(entity.authorCity, '南阳');
    expect(entity.authorRelationshipGoal, 'dating');
    expect(entity.authorPublicMbti, 'INFP');
    expect(entity.authorPublicPersonality, ['温和', '慢热']);
    expect(entity.likesCount, 8);
    expect(entity.likedByViewer, isTrue);
    expect(entity.coverMediaAssetId, 42);
    expect(entity.coverMediaUrl, 'https://example.com/cover.png');
    expect(entity.hasMedia, isTrue);
  });
}
