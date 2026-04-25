// ignore_for_file: invalid_use_of_internal_member

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_livekit_join_info_entity.dart';
import 'package:livekit_client/livekit_client.dart';

class RtcLiveKitService extends ChangeNotifier {
  RtcLiveKitService({required this.remoteDataSource, required this.appEnv});

  final RtcRemoteDataSource remoteDataSource;
  final AppEnv appEnv;

  Room? _room;
  int? _connectedCallId;
  bool _connecting = false;
  Timer? _heartbeatTimer;
  Timer? _audioStatsTimer;
  CancelListenFunc? _cancelLocalAudioRenderer;
  bool _heartbeatInFlight = false;
  bool _audioPlaybackRetryRequested = false;
  bool _remoteAudioTrackFromEvent = false;
  AudioTrack? _remoteAudioTrack;
  String? _boundLocalAudioTrackId;

  bool get isEnabled => appEnv.useLiveKitRtc;
  bool get isConnected => _room != null && _connectedCallId != null;
  int? get connectedCallId => _connectedCallId;
  AudioTrack? get remoteAudioTrack => _remoteAudioTrack;

  String _maskToken(String token) {
    if (token.length <= 16) {
      return token;
    }
    return '${token.substring(0, 12)}...${token.substring(token.length - 8)}';
  }

  String _platformLabel() {
    return defaultTargetPlatform.name;
  }

  String _expectedConnectUri(String url) {
    final uri = Uri.parse(url);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final pathSegments = <String>[
      ...uri.pathSegments.where((segment) => segment.isNotEmpty),
      'rtc',
    ];
    return uri.replace(scheme: scheme, pathSegments: pathSegments).toString();
  }

  String _expectedValidateUri(String url) {
    final uri = Uri.parse(url);
    final scheme = uri.scheme == 'https' ? 'https' : 'http';
    final pathSegments = <String>[
      ...uri.pathSegments.where((segment) => segment.isNotEmpty),
      'rtc',
      'validate',
    ];
    return uri.replace(scheme: scheme, pathSegments: pathSegments).toString();
  }

  void _logJoinInfo({
    required int callId,
    required RtcLiveKitJoinInfoEntity info,
  }) {
    debugPrint(
      'RTC_LIVEKIT_JOIN_INFO '
      'device=${_platformLabel()} '
      'callId=$callId '
      'url=${info.url} '
      'room=${info.roomName} '
      'identity=${info.identity} '
      'participant=${info.participantName} '
      'mode=${info.mode} '
      'expected_connect=${_expectedConnectUri(info.url)} '
      'expected_validate=${_expectedValidateUri(info.url)} '
      'token=${_maskToken(info.token)}',
    );
  }

  void _logRoomSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) {
    final localParticipant = room.localParticipant;
    debugPrint(
      'RTC_LIVEKIT_ROOM_SNAPSHOT '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'room=${room.name ?? "none"} '
      'remoteParticipants=${room.remoteParticipants.length} '
      'localAudioPubs=${localParticipant?.audioTrackPublications.length ?? 0} '
      'localVideoPubs=${localParticipant?.videoTrackPublications.length ?? 0}',
    );

    for (final participant in room.remoteParticipants.values) {
      final audioPubs = participant.audioTrackPublications
          .map((publication) {
            return 'sid=${publication.sid} kind=${publication.kind} source=${publication.source} '
                'subscribed=${publication.subscribed} muted=${publication.muted} '
                'track=${publication.track?.runtimeType}';
          })
          .join(' | ');
      debugPrint(
        'RTC_LIVEKIT_REMOTE_PARTICIPANT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'identity=${participant.identity} '
        'sid=${participant.sid} '
        'state=${participant.state} '
        'isSpeaking=${participant.isSpeaking} '
        'audioLevel=${participant.audioLevel} '
        'audioPubs=${participant.audioTrackPublications.length} '
        '${audioPubs.isEmpty ? "" : audioPubs}',
      );
    }
  }

  void _startHeartbeat(int callId) {
    if (!isEnabled) return;
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      unawaited(_sendHeartbeat(callId));
    });
    unawaited(_sendHeartbeat(callId));
  }

  Future<void> _sendHeartbeat(int callId) async {
    if (!isEnabled || _connectedCallId != callId) return;
    if (_heartbeatInFlight) return;
    _heartbeatInFlight = true;
    try {
      final session = await remoteDataSource.heartbeatCall(callId);
      debugPrint(
        'RTC_LIVEKIT_HEARTBEAT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'status=${session.status} '
        'isTerminal=${session.isTerminal}',
      );
      if (session.isTerminal) {
        await leave(callId: callId);
      }
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_HEARTBEAT_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'error=$error',
      );
    } finally {
      _heartbeatInFlight = false;
    }
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _heartbeatInFlight = false;
  }

  void _startAudioStatsTimer(int callId) {
    _audioStatsTimer?.cancel();
    _audioStatsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      unawaited(_logRemoteAudioStats(callId));
    });
    unawaited(_logRemoteAudioStats(callId));
  }

  void _stopAudioStatsTimer() {
    _audioStatsTimer?.cancel();
    _audioStatsTimer = null;
  }

  Future<void> _bindLocalAudioTrackDiagnostics(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'track=none '
        'localParticipant=none',
      );
      return;
    }

    AudioTrack? nextTrack;
    String? nextTrackId;
    for (final publication in localParticipant.audioTrackPublications) {
      final track = publication.track;
      if (track != null) {
        nextTrack = track;
        nextTrackId = track.mediaStreamTrack.id;
        break;
      }
    }

    if (nextTrack == null || nextTrackId == null) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'track=none '
        'audioPubs=${localParticipant.audioTrackPublications.length} '
        'boundTrack=${_boundLocalAudioTrackId ?? "none"}',
      );
      return;
    }

    if (_boundLocalAudioTrackId == nextTrackId) {
      return;
    }

    await _unbindLocalAudioTrackDiagnostics();
    _boundLocalAudioTrackId = nextTrackId;
    debugPrint(
      'RTC_LIVEKIT_LOCAL_AUDIO_BIND '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'trackId=$nextTrackId '
      'kind=${nextTrack.kind}',
    );

    try {
      var localFrameCount = 0;
      _cancelLocalAudioRenderer = nextTrack.addAudioRenderer(
        onFrame: (frame) {
          localFrameCount += 1;
          final sampleCount = frame.data.lengthInBytes ~/ 2;
          if (sampleCount <= 0) return;
          final samples = frame.data.buffer.asInt16List(
            frame.data.offsetInBytes,
            sampleCount,
          );
          final absAvg = samples.isEmpty
              ? 0.0
              : samples.fold<double>(
                    0.0,
                    (sum, sample) => sum + sample.abs().toDouble(),
                  ) /
                  samples.length /
                  32768.0;
          final peak = samples.isEmpty
              ? 0.0
              : samples
                  .map((sample) => sample.abs().toDouble())
                  .fold<double>(0.0, math.max) /
                  32768.0;
          if (absAvg > 0.0001 || peak > 0.0001) {
            debugPrint(
              'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
              'device=${_platformLabel()} '
              'callId=$callId '
              'reason=$reason '
              'trackId=$nextTrackId '
              'sampleRate=${frame.sampleRate} '
              'channels=${frame.channels} '
              'bytes=${frame.data.lengthInBytes} '
              'absAvg=${absAvg.toStringAsFixed(4)} '
              'peak=${peak.toStringAsFixed(4)}',
            );
          } else if (localFrameCount == 1 || localFrameCount % 25 == 0) {
            debugPrint(
              'RTC_LIVEKIT_LOCAL_AUDIO_FRAME '
              'device=${_platformLabel()} '
              'callId=$callId '
              'reason=$reason '
              'trackId=$nextTrackId '
              'sampleRate=${frame.sampleRate} '
              'channels=${frame.channels} '
              'bytes=${frame.data.lengthInBytes} '
              'absAvg=${absAvg.toStringAsFixed(4)} '
              'peak=${peak.toStringAsFixed(4)}',
            );
          }
        },
        options: const AudioRendererOptions(
          sampleRate: 24000,
          channels: 1,
          format: AudioFormat.Int16,
        ),
      );
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO_BIND_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'trackId=$nextTrackId '
        'error=$error',
      );
    }
  }

  Future<void> _unbindLocalAudioTrackDiagnostics() async {
    final cancel = _cancelLocalAudioRenderer;
    _cancelLocalAudioRenderer = null;
    _boundLocalAudioTrackId = null;
    if (cancel != null) {
      try {
        await cancel();
      } catch (_) {
        // best-effort only
      }
    }
  }

  Future<void> _logRemoteAudioStats(int callId) async {
    final room = _room;
    final track = _remoteAudioTrack;
    if (room == null) return;
    if (track == null) {
      debugPrint(
        'RTC_LIVEKIT_REMOTE_AUDIO_STATS '
        'device=${_platformLabel()} '
        'callId=$callId '
        'track=none '
        'remoteParticipants=${room.remoteParticipants.length}',
      );
      return;
    }

    final receiver = track.receiver;
    final trackId = track.mediaStreamTrack.id;
    final enabled = track.mediaStreamTrack.enabled;
    final muted = track.muted;
    final isActive = track.isActive;
    final receiverState = receiver == null ? 'none' : 'present';
    final trackLabel = track.mediaStreamTrack.label ?? 'unknown';
    final trackKind = track.mediaStreamTrack.kind ?? 'unknown';
    String statsSummary = 'stats=unavailable';

    if (receiver != null) {
      try {
        final reports = await receiver.getStats();
        for (final report in reports) {
          if (report.type == 'inbound-rtp') {
            final values = report.values;
            final bytesReceived = values['bytesReceived']?.toString();
            final packetsReceived = values['packetsReceived']?.toString();
            final totalAudioEnergy = values['totalAudioEnergy']?.toString();
            final totalSamplesDuration = values['totalSamplesDuration']
                ?.toString();
            statsSummary =
                'stats=inbound bytesReceived=$bytesReceived packetsReceived=$packetsReceived '
                'totalAudioEnergy=$totalAudioEnergy totalSamplesDuration=$totalSamplesDuration';
            break;
          }
        }
      } catch (error) {
        statsSummary = 'stats_error=$error';
      }
    }

    debugPrint(
      'RTC_LIVEKIT_REMOTE_AUDIO_STATS '
      'device=${_platformLabel()} '
      'callId=$callId '
      'trackId=$trackId '
      'trackKind=$trackKind '
      'trackLabel=$trackLabel '
      'receiver=$receiverState '
      'enabled=$enabled '
      'muted=$muted '
      'active=$isActive '
      '$statsSummary',
    );
  }

  Future<void> _logPeerConnectionSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    Future<String> describePeer(dynamic pc) async {
      if (pc == null) return 'none';
      var signaling = 'unknown';
      try {
        signaling = (await pc.getSignalingState()).toString();
      } catch (error) {
        signaling = 'error:$error';
      }
      return 'connection=${pc.connectionState} ice=${pc.iceConnectionState} signaling=$signaling';
    }

    final publisher = await describePeer(room.engine.publisher?.pc);
    final subscriber = await describePeer(room.engine.subscriber?.pc);
    debugPrint(
      'RTC_LIVEKIT_PEER_CONNECTION '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'roomConnection=${room.connectionState} '
      'engineConnection=${room.engine.connectionState} '
      'publisher={$publisher} '
      'subscriber={$subscriber}',
    );
  }

  Future<void> _ensureAudioPlayback(
    Room room, {
    required int callId,
    required String reason,
  }) async {
    try {
      try {
        await room.setSpeakerOn(true, forceSpeakerOutput: true);
      } catch (error) {
        debugPrint(
          'RTC_LIVEKIT_AUDIO_ROUTE_FORCE_FAIL '
          'device=${_platformLabel()} '
          'callId=$callId '
          'reason=$reason '
          'error=$error',
        );
      }
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_START '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'canPlaybackBefore=${room.canPlaybackAudio}',
      );
      await room.startAudio();
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_READY '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'canPlaybackAfter=${room.canPlaybackAudio}',
      );
      _startAudioStatsTimer(callId);
    } catch (error) {
      debugPrint(
        'RTC_LIVEKIT_AUDIO_PLAYBACK_START_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'error=$error',
      );
    }
  }

  void _logLocalAudioSnapshot(
    Room room, {
    required int callId,
    required String reason,
  }) {
    final localParticipant = room.localParticipant;
    if (localParticipant == null) {
      debugPrint(
        'RTC_LIVEKIT_LOCAL_AUDIO '
        'device=${_platformLabel()} '
        'callId=$callId '
        'reason=$reason '
        'localParticipant=none',
      );
      return;
    }

    final pubs = localParticipant.audioTrackPublications
        .map((publication) {
          return 'sid=${publication.sid} source=${publication.source} muted=${publication.muted} '
              'subscribed=${publication.subscribed} track=${publication.track?.runtimeType}';
        })
        .join(' | ');

    debugPrint(
      'RTC_LIVEKIT_LOCAL_AUDIO '
      'device=${_platformLabel()} '
      'callId=$callId '
      'reason=$reason '
      'audioPubs=${localParticipant.audioTrackPublications.length} '
      '${pubs.isEmpty ? "" : pubs}',
    );
  }

  void _refreshRemoteAudioTrack(Room room, {String reason = 'unknown'}) {
    AudioTrack? nextTrack;
    String? nextParticipant;
    for (final participant in room.remoteParticipants.values) {
      for (final publication in participant.audioTrackPublications) {
        final track = publication.track;
        if (track != null && publication.subscribed) {
          nextTrack = track;
          nextParticipant = participant.identity;
          break;
        }
      }
      if (nextTrack != null) break;
    }

    final currentId = _remoteAudioTrack?.mediaStreamTrack.id;
    final nextId = nextTrack?.mediaStreamTrack.id;
    if (nextTrack == null) {
      debugPrint(
        'RTC_LIVEKIT_REMOTE_AUDIO_REFRESH reason=$reason '
        'device=${_platformLabel()} '
        'callId=${_connectedCallId ?? -1} '
        'participant=none '
        'trackId=${currentId ?? "none"} '
        'roomParticipants=${room.remoteParticipants.length} '
        'source=${_remoteAudioTrackFromEvent ? "event" : "scan"} '
        'preserved=${currentId != null ? "yes" : "no"}',
      );
      return;
    }
    if (currentId == nextId) {
      return;
    }

    _remoteAudioTrack = nextTrack;
    _remoteAudioTrackFromEvent = false;
    debugPrint(
      'RTC_LIVEKIT_REMOTE_AUDIO_REFRESH reason=$reason '
      'device=${_platformLabel()} '
      'callId=${_connectedCallId ?? -1} '
      'participant=${nextParticipant ?? "none"} '
      'trackId=${nextId ?? "none"} '
      'roomParticipants=${room.remoteParticipants.length}',
    );
    notifyListeners();
  }

  Future<void> ensureConnected(int callId) async {
    if (!isEnabled || callId <= 0) return;
    if (_connectedCallId == callId && _room != null) return;
    if (_connecting) return;
    _connecting = true;
    try {
      final info = await _loadJoinInfo(callId);
      if (info == null || !info.isReady) return;
      _logJoinInfo(callId: callId, info: info);
      await leave();
      _connectedCallId = callId;
      _startHeartbeat(callId);
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE_PRECONNECT '
        'device=${_platformLabel()} '
        'callId=$callId '
        'speakerOn=${Hardware.instance.speakerOn} '
        'forceSpeaker=${Hardware.instance.forceSpeakerOutput}',
      );

      final room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
          defaultAudioOutputOptions: AudioOutputOptions(speakerOn: true),
        ),
      );
      final connectOptions = ConnectOptions(
        timeouts: const Timeouts(
          connection: Duration(seconds: 30),
          debounce: Duration(milliseconds: 20),
          publish: Duration(seconds: 30),
          subscribe: Duration(seconds: 30),
          peerConnection: Duration(seconds: 30),
          iceRestart: Duration(seconds: 30),
        ),
      );
      room.events
        ..on<RoomConnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'room_connected');
        })
        ..on<ParticipantConnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_connected');
        })
        ..on<ParticipantDisconnectedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_disconnected');
        })
      ..on<TrackSubscribedEvent>((event) {
        if (event.track is AudioTrack) {
          _remoteAudioTrack = event.track as AudioTrack;
          _remoteAudioTrackFromEvent = true;
          notifyListeners();
            unawaited(
              _ensureAudioPlayback(
                room,
                callId: callId,
                reason: 'track_subscribed',
              ),
            );
          }
          unawaited(
            _logPeerConnectionSnapshot(
              room,
              callId: callId,
              reason: 'track_subscribed',
            ),
          );
          debugPrint(
            'RTC_LIVEKIT_TRACK_SUBSCRIBED callId=$callId '
            'device=${_platformLabel()} '
            'participant=${event.participant.identity} '
            'trackSid=${event.publication.sid} '
            'kind=${event.track.kind}',
          );
          _logRoomSnapshot(room, callId: callId, reason: 'track_subscribed');
        })
        ..on<TrackUnsubscribedEvent>((event) {
          if (_remoteAudioTrack?.mediaStreamTrack.id ==
              event.track.mediaStreamTrack.id) {
            _remoteAudioTrack = null;
            _remoteAudioTrackFromEvent = false;
            notifyListeners();
          }
          _refreshRemoteAudioTrack(room, reason: 'track_unsubscribed');
        })
        ..on<TrackPublishedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_published');
          unawaited(
            _bindLocalAudioTrackDiagnostics(
              room,
              callId: callId,
              reason: 'track_published',
            ),
          );
        })
        ..on<TrackUnpublishedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_unpublished');
        })
        ..on<TrackMutedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_muted');
        })
        ..on<TrackUnmutedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'track_unmuted');
        })
        ..on<ParticipantStateUpdatedEvent>((event) {
          _refreshRemoteAudioTrack(room, reason: 'participant_state_updated');
        })
        ..on<AudioPlaybackStatusChanged>((event) {
          debugPrint(
            'RTC_LIVEKIT_AUDIO_PLAYBACK callId=$callId '
            'device=${_platformLabel()} '
            'isPlaying=${event.isPlaying} '
            'canPlayback=${room.canPlaybackAudio}',
          );
          if (!event.isPlaying && !_audioPlaybackRetryRequested) {
            _audioPlaybackRetryRequested = true;
            unawaited(
              Future<void>.delayed(const Duration(milliseconds: 300), () async {
                try {
                  await _ensureAudioPlayback(
                    room,
                    callId: callId,
                    reason: 'playback_status_retry',
                  );
                } finally {
                  _audioPlaybackRetryRequested = false;
                }
              }),
            );
          }
        })
        ..on<TrackSubscriptionExceptionEvent>((event) {
          debugPrint(
            'RTC_LIVEKIT_TRACK_SUBSCRIBE_FAILED callId=$callId '
            'device=${_platformLabel()} '
            'participant=${event.participant?.identity ?? "unknown"} '
            'trackSid=${event.sid} '
            'reason=${event.reason}',
          );
        });
      debugPrint(
        'RTC_LIVEKIT_CONNECT_TIMEOUTS '
        'device=${_platformLabel()} '
        'callId=$callId '
        'connection=30s publish=30s subscribe=30s '
        'peerConnection=30s iceRestart=30s',
      );
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_START '
        'device=${_platformLabel()} '
        'callId=$callId '
        'url=${info.url} '
        'room=${info.roomName} '
        'identity=${info.identity}',
      );
      await room.connect(info.url, info.token, connectOptions: connectOptions);
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_OK '
        'device=${_platformLabel()} '
        'callId=$callId '
        'room=${room.name ?? info.roomName} '
        'remoteParticipants=${room.remoteParticipants.length}',
      );
      await _logPeerConnectionSnapshot(
        room,
        callId: callId,
        reason: 'after_connect',
      );
      _refreshRemoteAudioTrack(room, reason: 'after_connect');
      await _ensureAudioPlayback(room, callId: callId, reason: 'after_connect');
      debugPrint(
        'RTC_LIVEKIT_AUDIO_ROUTE '
        'device=${_platformLabel()} '
        'callId=$callId '
        'canPlaybackAudio=${room.canPlaybackAudio}',
      );
      _logLocalAudioSnapshot(room, callId: callId, reason: 'after_set_speaker');
      await room.localParticipant?.setMicrophoneEnabled(true);
      _logLocalAudioSnapshot(
        room,
        callId: callId,
        reason: 'after_enable_microphone',
      );
      unawaited(
        _bindLocalAudioTrackDiagnostics(
          room,
          callId: callId,
          reason: 'after_enable_microphone',
        ),
      );

      _room = room;
      _connectedCallId = callId;
      _refreshRemoteAudioTrack(room, reason: 'after_enable_audio');
      unawaited(
        _bindLocalAudioTrackDiagnostics(
          room,
          callId: callId,
          reason: 'after_enable_audio',
        ),
      );
      _logRoomSnapshot(room, callId: callId, reason: 'after_enable_audio');
      _startHeartbeat(callId);
      _startAudioStatsTimer(callId);
      notifyListeners();
    } catch (error) {
      await leave(callId: callId);
      debugPrint(
        'RTC_LIVEKIT_ROOM_CONNECT_FAIL '
        'device=${_platformLabel()} '
        'callId=$callId '
        'error=$error',
      );
      rethrow;
    } finally {
      _connecting = false;
    }
  }

  Future<void> leave({int? callId}) async {
    if (!isEnabled) return;
    if (callId != null && _connectedCallId != callId) return;
    final room = _room;
    _room = null;
    _connectedCallId = null;
    _remoteAudioTrack = null;
    _remoteAudioTrackFromEvent = false;
    _stopHeartbeat();
    _stopAudioStatsTimer();
    unawaited(_unbindLocalAudioTrackDiagnostics());
    notifyListeners();
    if (room == null) return;
    try {
      await room.disconnect();
    } catch (_) {
      // leave should be best-effort only.
    }
  }

  Future<RtcLiveKitJoinInfoEntity?> _loadJoinInfo(int callId) async {
    try {
      return await remoteDataSource.fetchLiveKitJoinInfo(callId);
    } catch (_) {
      return null;
    }
  }
}
