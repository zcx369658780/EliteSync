import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';

void main() {
  test('MessageDto parses attachments and content fallback', () {
    final dto = MessageDto.fromJson({
      'id': '42',
      'mine': true,
      'content': 'hello',
      'time': '2026-04-18T12:00:00.000Z',
      'attachments': [
        {
          'id': 7,
          'attachment_type': 'image',
          'media_asset': {
            'id': 99,
            'media_type': 'image',
            'public_url': 'https://cdn.example.test/a.jpg',
            'status': 'ready',
            'mime_type': 'image/jpeg',
            'size_bytes': 1024,
            'width': 800,
            'height': 600,
          },
        },
      ],
    });

    expect(dto.id, '42');
    expect(dto.mine, isTrue);
    expect(dto.text, 'hello');
    expect(dto.attachments, hasLength(1));
    expect(dto.hasAttachments, isTrue);
    expect(dto.hasImageAttachment, isTrue);
    expect(dto.attachments.first.publicUrl, 'https://cdn.example.test/a.jpg');
  });
}
