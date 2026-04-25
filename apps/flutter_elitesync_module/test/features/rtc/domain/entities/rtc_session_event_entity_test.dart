import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_event_entity.dart';

void main() {
  test('RtcSessionEventEntity treats list payload as empty map', () {
    final entity = RtcSessionEventEntity.fromJson({
      'id': 1,
      'event_name': 'accepted',
      'user_id': 8,
      'payload': const [],
      'created_at': '2026-04-23T00:39:09.000000Z',
    });

    expect(entity.payload, isEmpty);
    expect(entity.eventName, 'accepted');
    expect(entity.userId, 8);
  });

  test('RtcSessionEventEntity keeps map payload content', () {
    final entity = RtcSessionEventEntity.fromJson({
      'id': 2,
      'event_name': 'created',
      'user_id': 7,
      'payload': {
        'mode': 'voice',
        'peer_busy': false,
      },
      'created_at': '2026-04-23T00:39:08.000000Z',
    });

    expect(entity.payload['mode'], 'voice');
    expect(entity.payload['peer_busy'], false);
  });
}
