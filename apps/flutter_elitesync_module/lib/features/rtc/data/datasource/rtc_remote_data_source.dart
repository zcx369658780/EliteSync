import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';

class RtcRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 8);

  RtcRemoteDataSource({required this.apiClient});

  final ApiClient apiClient;

  Future<List<RtcSessionEntity>> fetchCalls() async {
    final result = await apiClient.get('/api/v1/rtc/calls').timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final items = (result.data['items'] as List<dynamic>? ?? const []);
      return items.whereType<Map<String, dynamic>>().map(RtcSessionEntity.fromJson).toList();
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<RtcSessionEntity> fetchCall(int callId) async {
    final result = await apiClient.get('/api/v1/rtc/calls/$callId').timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final session = result.data['session'];
      if (session is Map<String, dynamic>) {
        return RtcSessionEntity.fromJson(session);
      }
      throw Exception('rtc session missing');
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<RtcSessionEntity> createCall({
    required int peerUserId,
    String mode = 'voice',
  }) async {
    final result = await apiClient.post(
      '/api/v1/rtc/calls',
      body: <String, dynamic>{
        'peer_user_id': peerUserId,
        'mode': mode,
      },
    ).timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final session = result.data['session'];
      if (session is Map<String, dynamic>) {
        return RtcSessionEntity.fromJson(session);
      }
      throw Exception('rtc session missing');
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<RtcSessionEntity> acceptCall(int callId) async {
    return _postSession('/api/v1/rtc/calls/$callId/accept');
  }

  Future<RtcSessionEntity> connectCall(int callId) async {
    return _postSession('/api/v1/rtc/calls/$callId/connect');
  }

  Future<RtcSessionEntity> rejectCall(int callId) async {
    return _postSession('/api/v1/rtc/calls/$callId/reject');
  }

  Future<RtcSessionEntity> endCall(int callId) async {
    return _postSession('/api/v1/rtc/calls/$callId/end');
  }

  Future<RtcSessionEntity> heartbeatCall(int callId) async {
    return _postSession('/api/v1/rtc/calls/$callId/heartbeat');
  }

  Future<RtcLiveKitJoinInfoEntity> fetchLiveKitJoinInfo(int callId) async {
    final result = await apiClient
        .get('/api/v1/rtc/calls/$callId/livekit')
        .timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final livekit = result.data['livekit'];
      if (livekit is Map<String, dynamic>) {
        return RtcLiveKitJoinInfoEntity.fromJson(livekit);
      }
      throw Exception('rtc livekit join info missing');
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<RtcSessionEntity> _postSession(String path) async {
    final result = await apiClient.post(path, body: const <String, dynamic>{}).timeout(_requestTimeout);
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final session = result.data['session'];
      if (session is Map<String, dynamic>) {
        return RtcSessionEntity.fromJson(session);
      }
      throw Exception('rtc session missing');
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }
}
