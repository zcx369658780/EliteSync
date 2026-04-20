import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/data/datasource/chat_socket_data_source.dart';

void main() {
  test('buildChatSocketUri maps http api base to ws gateway host and port', () {
    final uri = buildChatSocketUri(
      apiBaseUrl: 'http://101.133.161.203',
      selfId: 37,
    );

    expect(uri.toString(), 'ws://101.133.161.203:8081/api/v1/messages/ws/37');
  });

  test('buildChatSocketUri maps https api base to wss gateway without port', () {
    final uri = buildChatSocketUri(
      apiBaseUrl: 'https://slowdate.top',
      selfId: 8,
    );

    expect(uri.toString(), 'wss://slowdate.top/api/v1/messages/ws/8');
  });

  test('decodeChatSocketEvent keeps only paired message events', () {
    final dto = decodeChatSocketEvent(
      '{"type":"message","id":11,"sender_id":7,"receiver_id":8,"content":"hello","created_at":"2026-04-19T12:00:00Z"}',
      selfId: 8,
      peerId: 7,
    );

    expect(dto, isNotNull);
    expect(dto!.id, '11');
    expect(dto.mine, isFalse);
    expect(dto.text, 'hello');
  });
}
