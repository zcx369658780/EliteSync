import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';

NotificationItemEntity _invite({
  required int id,
  required bool read,
  String routeName = 'rtc_call',
  int callId = 15,
}) {
  return NotificationItemEntity(
    id: id,
    kind: 'rtc_call_invite',
    title: '来电',
    body: '有人发起了通话',
    payload: {
      'route_name': routeName,
      'route_args': {'call_id': callId},
    },
    routeName: routeName,
    routeArgs: {'call_id': callId},
    isRead: read,
    createdAt: '2026-04-22T12:00:00Z',
  );
}

RtcSessionEntity _call({
  required int id,
  required int peerUserId,
  required bool isIncoming,
  String status = 'calling',
}) {
  return RtcSessionEntity.fromJson({
    'id': id,
    'call_key': 'call-$id',
    'room_key': '7_8',
    'mode': 'voice',
    'status': status,
    'title': '语音通话',
    'initiator_user_id': isIncoming ? 7 : peerUserId,
    'peer_user_id': peerUserId,
    'initiator_name': 'Caller',
    'peer_name': 'Callee',
    'is_initiator': !isIncoming,
    'accepted_by_user_id': null,
    'ended_by_user_id': null,
    'failure_code': null,
    'failure_message': null,
    'ringing_at': '2026-04-23T00:00:00Z',
    'accepted_at': null,
    'started_at': null,
    'ended_at': null,
    'expires_at': '2026-04-23T00:00:10Z',
    'created_at': '2026-04-23T00:00:00Z',
    'updated_at': '2026-04-23T00:00:00Z',
    'latest_event_name': 'created',
    'events': const [],
    'is_active': true,
    'is_terminal': false,
  });
}

void main() {
  test('selectLatestRtcInvite returns the first unread rtc invite with call id', () {
    final selected = selectLatestRtcInvite([
      _invite(id: 1, read: true, callId: 10),
      _invite(id: 2, read: false, callId: 15),
      _invite(id: 3, read: false, routeName: 'settings', callId: 16),
    ]);

    expect(selected?.id, 2);
  });

  test('selectLatestRtcInvite ignores non invite or invalid call id items', () {
    final selected = selectLatestRtcInvite([
      _invite(id: 4, read: false, callId: 0),
      NotificationItemEntity(
        id: 5,
        kind: 'message',
        title: '消息',
        body: '正文',
        payload: const {},
        routeName: 'chat_room',
        routeArgs: const {},
        isRead: false,
        createdAt: '2026-04-22T12:00:00Z',
      ),
    ]);

    expect(selected, isNull);
  });

  test('selectLatestIncomingRtcCall returns the first incoming active call', () {
    final selected = selectLatestIncomingRtcCall([
      _call(id: 11, peerUserId: 8, isIncoming: false, status: 'calling'),
      _call(id: 12, peerUserId: 8, isIncoming: true, status: 'ringing'),
      _call(id: 13, peerUserId: 9, isIncoming: true, status: 'calling'),
    ], 8);

    expect(selected?.id, 12);
  });

  test('selectLatestIncomingRtcCall ignores terminal or outgoing calls', () {
    final selected = selectLatestIncomingRtcCall([
      _call(id: 21, peerUserId: 8, isIncoming: true, status: 'ended'),
      _call(id: 22, peerUserId: 8, isIncoming: false, status: 'calling'),
    ], 8);

    expect(selected, isNull);
  });
}
