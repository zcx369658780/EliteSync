import 'package:flutter_elitesync/core/network/api_client.dart';
import 'package:flutter_elitesync/core/network/network_result.dart';
import 'package:flutter_elitesync/features/chat/data/dto/conversation_dto.dart';
import 'package:flutter_elitesync/features/chat/data/dto/message_dto.dart';
import 'package:flutter_elitesync/features/chat/data/dto/send_message_request_dto.dart';
import 'package:flutter_elitesync/mocks/mock_data/chat_mock.dart';

class ChatRemoteDataSource {
  const ChatRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;

  Future<List<ConversationDto>> getConversations() async {
    if (useMock) {
      return ChatMock.conversationsHappy.map(ConversationDto.fromJson).toList();
    }
    final result = await apiClient.get('/api/v1/messages/list');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = (result.data['data'] as List<dynamic>? ?? const []);
      return list.whereType<Map<String, dynamic>>().map(ConversationDto.fromJson).toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<List<MessageDto>> getMessages(String conversationId) async {
    if (useMock) {
      return ChatMock.messagesHappy.map(MessageDto.fromJson).toList();
    }
    final result = await apiClient.get('/api/v1/messages/$conversationId');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final list = (result.data['data'] as List<dynamic>? ?? const []);
      return list.whereType<Map<String, dynamic>>().map(MessageDto.fromJson).toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<void> sendMessage(String conversationId, String text) async {
    if (useMock) return;
    final result = await apiClient.post('/api/v1/messages/$conversationId', body: SendMessageRequestDto(text: text).toJson());
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }
}
