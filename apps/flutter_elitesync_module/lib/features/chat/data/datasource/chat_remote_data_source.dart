import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/send_message_request_dto.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/chat_mock.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource({
    required this.apiClient,
    required this.localStorage,
    required this.useMock,
  });

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  final bool useMock;
  int? _cachedSelfId;

  Future<int> _selfId() async {
    if (_cachedSelfId != null && _cachedSelfId! > 0) return _cachedSelfId!;
    try {
      final local = await localStorage.getJson(CacheKeys.lastKnownProfile);
      final localId = (local?['id'] as num?)?.toInt();
      if (localId != null && localId > 0) {
        _cachedSelfId = localId;
        return localId;
      }
      final profile = await apiClient.get('/api/v1/profile/basic');
      if (profile is NetworkSuccess<Map<String, dynamic>>) {
        final id = (profile.data['id'] as num?)?.toInt() ?? 0;
        if (id > 0) {
          _cachedSelfId = id;
          return id;
        }
      }
    } catch (_) {}
    return 0;
  }

  Future<List<ConversationDto>> getConversations() async {
    if (useMock) {
      return ChatMock.conversationsHappy.map(ConversationDto.fromJson).toList();
    }
    // 1) Prefer current match.
    final current = await apiClient.get('/api/v1/match/current');
    if (current is NetworkSuccess<Map<String, dynamic>>) {
      final built = _conversationFromMatchPayload(current.data);
      if (built != null) return [built];
    }

    // 2) Fallback to latest history match.
    final history = await apiClient.get('/api/v1/match/history');
    if (history is NetworkSuccess<Map<String, dynamic>>) {
      final items = (history.data['items'] as List<dynamic>? ?? const []);
      for (final row in items) {
        if (row is! Map<String, dynamic>) continue;
        final built = _conversationFromMatchPayload(row);
        if (built != null) return [built];
      }
      return const [];
    }

    final failure = history as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<MessageDto>> getMessages(String conversationId) async {
    if (useMock) {
      return ChatMock.messagesHappy.map(MessageDto.fromJson).toList();
    }
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      throw Exception('invalid conversation id');
    }
    final selfId = await _selfId();
    final result = await apiClient.get('/api/v1/messages', query: {'peer_id': peerId, 'limit': 100});
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = (result.data['items'] as List<dynamic>? ?? const []);
      return list.whereType<Map<String, dynamic>>().map((raw) {
        final senderId = (raw['sender_id'] as num?)?.toInt() ?? 0;
        final text = (raw['content'] ?? '').toString();
        final createdAt = (raw['created_at'] ?? '').toString();
        return MessageDto(
          id: (raw['id'] ?? '').toString(),
          mine: selfId > 0 && senderId == selfId,
          text: text,
          time: createdAt,
        );
      }).toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (useMock) return;
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      throw Exception('invalid conversation id');
    }
    final result = await apiClient.post(
      '/api/v1/messages',
      body: SendMessageRequestDto(
        receiverId: peerId,
        content: text,
      ).toJson(),
    );
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  ConversationDto? _conversationFromMatchPayload(Map<String, dynamic> payload) {
    final partnerId = (payload['partner_id'] as num?)?.toInt();
    if (partnerId == null || partnerId <= 0) return null;
    final partnerNickname = (payload['partner_nickname'] ?? '').toString().trim();
    final displayName = partnerNickname.isNotEmpty ? partnerNickname : '匹配对象 #$partnerId';
    final score = (payload['final_score'] as num?)?.toInt();
    final highlights = (payload['highlights'] as String?) ?? '';
    return ConversationDto(
      id: partnerId.toString(),
      name: displayName,
      lastMessage: highlights.isNotEmpty ? highlights : '已建立匹配，开始聊天吧',
      lastTime: score == null ? '刚刚' : '匹配分 $score',
      unread: 0,
    );
  }
}
