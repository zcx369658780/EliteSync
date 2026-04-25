import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_event_entity.dart';

class RtcSessionEntity {
  const RtcSessionEntity({
    required this.id,
    required this.callKey,
    required this.roomKey,
    required this.mode,
    required this.status,
    required this.title,
    required this.initiatorUserId,
    required this.peerUserId,
    required this.initiatorName,
    required this.peerName,
    required this.isInitiator,
    required this.acceptedByUserId,
    required this.endedByUserId,
    required this.failureCode,
    required this.failureMessage,
    required this.ringingAt,
    required this.acceptedAt,
    required this.startedAt,
    required this.endedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
    required this.latestEventName,
    required this.events,
    required this.isActive,
    required this.isTerminal,
  });

  final int id;
  final String callKey;
  final String roomKey;
  final String mode;
  final String status;
  final String title;
  final int initiatorUserId;
  final int peerUserId;
  final String initiatorName;
  final String peerName;
  final bool isInitiator;
  final int? acceptedByUserId;
  final int? endedByUserId;
  final String? failureCode;
  final String? failureMessage;
  final String? ringingAt;
  final String? acceptedAt;
  final String? startedAt;
  final String? endedAt;
  final String? expiresAt;
  final String? createdAt;
  final String? updatedAt;
  final String? latestEventName;
  final List<RtcSessionEventEntity> events;
  final bool isActive;
  final bool isTerminal;

  bool get isIncoming => !isInitiator;
  bool get canAccept => status == 'calling' || status == 'ringing';
  bool get canConnect => status == 'connecting';
  bool get canHangup => ['calling', 'ringing', 'connecting', 'in_call', 'busy'].contains(status);

  factory RtcSessionEntity.fromJson(Map<String, dynamic> json) {
    final events = (json['events'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(RtcSessionEventEntity.fromJson)
        .toList();
    return RtcSessionEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      callKey: (json['call_key'] ?? '').toString(),
      roomKey: (json['room_key'] ?? '').toString(),
      mode: (json['mode'] ?? 'voice').toString(),
      status: (json['status'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      initiatorUserId: (json['initiator_user_id'] as num?)?.toInt() ?? 0,
      peerUserId: (json['peer_user_id'] as num?)?.toInt() ?? 0,
      initiatorName: (json['initiator_name'] ?? '').toString(),
      peerName: (json['peer_name'] ?? '').toString(),
      isInitiator: (json['is_initiator'] as bool?) ?? false,
      acceptedByUserId: (json['accepted_by_user_id'] as num?)?.toInt(),
      endedByUserId: (json['ended_by_user_id'] as num?)?.toInt(),
      failureCode: json['failure_code']?.toString(),
      failureMessage: json['failure_message']?.toString(),
      ringingAt: json['ringing_at']?.toString(),
      acceptedAt: json['accepted_at']?.toString(),
      startedAt: json['started_at']?.toString(),
      endedAt: json['ended_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      latestEventName: json['latest_event_name']?.toString(),
      events: events,
      isActive: (json['is_active'] as bool?) ?? false,
      isTerminal: (json['is_terminal'] as bool?) ?? false,
    );
  }
}
