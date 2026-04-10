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

  test('status post entity still labels non-synthetic test accounts correctly', () {
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
  });
}
