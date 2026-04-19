import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';

bool isSupportedConversationId(String id, {required bool allowMockIds}) {
  final trimmed = id.trim();
  if (trimmed.isEmpty) return false;
  if (allowMockIds) return true;
  return int.tryParse(trimmed) != null;
}

List<ConversationEntity> sanitizeConversationSnapshot(
  List<ConversationEntity> items, {
  required bool allowMockIds,
}) {
  return items
      .where(
        (item) =>
            isSupportedConversationId(item.id, allowMockIds: allowMockIds),
      )
      .toList(growable: false);
}
