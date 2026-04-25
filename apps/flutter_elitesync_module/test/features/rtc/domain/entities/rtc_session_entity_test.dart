import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';

void main() {
  test('RtcSessionEntity parses voice call payload', () {
    final session = RtcSessionEntity.fromJson({
      'id': 11,
      'call_key': 'call-11',
      'room_key': '1_2',
      'mode': 'voice',
      'status': 'calling',
      'title': '语音通话',
      'initiator_user_id': 1,
      'peer_user_id': 2,
      'initiator_name': 'Alice',
      'peer_name': 'Bob',
      'is_initiator': true,
      'accepted_by_user_id': null,
      'ended_by_user_id': null,
      'failure_code': null,
      'failure_message': null,
      'ringing_at': '2026-04-21T12:00:00Z',
      'accepted_at': null,
      'started_at': null,
      'ended_at': null,
      'expires_at': '2026-04-21T12:02:00Z',
      'created_at': '2026-04-21T12:00:00Z',
      'updated_at': '2026-04-21T12:00:00Z',
      'latest_event_name': 'created',
      'events': const [],
      'is_active': true,
      'is_terminal': false,
    });

    expect(session.id, 11);
    expect(session.mode, 'voice');
    expect(session.status, 'calling');
    expect(session.isInitiator, isTrue);
    expect(session.canAccept, isTrue);
    expect(session.canHangup, isTrue);
  });
}
