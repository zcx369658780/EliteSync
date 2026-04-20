import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/media/media_url_resolver.dart';

void main() {
  test('resolveMediaUrl rewrites localhost storage url to api host', () {
    final resolved = resolveMediaUrl(
      'http://localhost:8080/storage/chat-media/7/image/a.jpg',
      apiBaseUrl: 'http://101.133.161.203',
    );

    expect(
      resolved,
      'http://101.133.161.203/storage/chat-media/7/image/a.jpg',
    );
  });

  test('resolveMediaUrl resolves relative storage paths against api host', () {
    final resolved = resolveMediaUrl(
      '/storage/chat-media/7/video/a.mp4',
      apiBaseUrl: 'http://101.133.161.203',
    );

    expect(
      resolved,
      'http://101.133.161.203/storage/chat-media/7/video/a.mp4',
    );
  });

  test('resolveMediaUrl keeps external urls intact', () {
    const url = 'https://cdn.example.test/chat/a.jpg';

    expect(
      resolveMediaUrl(url, apiBaseUrl: 'http://101.133.161.203'),
      url,
    );
  });
}
