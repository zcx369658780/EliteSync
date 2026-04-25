import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';

void main() {
  test('RtcLiveKitJoinInfoEntity parses join payload', () {
    final entity = RtcLiveKitJoinInfoEntity.fromJson({
      'enabled': true,
      'url': 'wss://rtc.example.test',
      'token': 'jwt-token',
      'room_name': '1_2',
      'identity': 'rtc-user-7',
      'participant_name': 'Caller',
      'mode': 'voice',
      'expires_at': '2026-04-23T12:00:00Z',
    });

    expect(entity.isReady, isTrue);
    expect(entity.url, 'wss://rtc.example.test');
    expect(entity.roomName, '1_2');
    expect(entity.identity, 'rtc-user-7');
    expect(entity.mode, 'voice');
  });
}

