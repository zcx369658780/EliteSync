import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/domain/utils/conversation_snapshot_utils.dart';

void main() {
  test('sanitizeConversationSnapshot drops non-numeric ids in prod mode', () {
    const items = [
      ConversationEntity(
        id: 'c001',
        name: '晨雾',
        lastMessage: '图片消息',
        lastTime: '10:18',
        unread: 2,
      ),
      ConversationEntity(
        id: '38',
        name: '九紫瑶瑶',
        lastMessage: '你好',
        lastTime: '昨天',
        unread: 0,
      ),
    ];

    final sanitized = sanitizeConversationSnapshot(items, allowMockIds: false);

    expect(sanitized, hasLength(1));
    expect(sanitized.single.id, '38');
  });

  test('sanitizeConversationSnapshot keeps mock ids in mock mode', () {
    const items = [
      ConversationEntity(
        id: 'c001',
        name: '晨雾',
        lastMessage: '图片消息',
        lastTime: '10:18',
        unread: 2,
      ),
      ConversationEntity(
        id: '38',
        name: '九紫瑶瑶',
        lastMessage: '你好',
        lastTime: '昨天',
        unread: 0,
      ),
    ];

    final sanitized = sanitizeConversationSnapshot(items, allowMockIds: true);

    expect(sanitized, hasLength(2));
  });
}
