import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/chat/data/dto/message_dto.dart';

Uri buildChatSocketUri({
  required String apiBaseUrl,
  required int selfId,
}) {
  final apiUri = Uri.tryParse(apiBaseUrl.trim());
  final host = apiUri?.host.isNotEmpty == true ? apiUri!.host : '127.0.0.1';
  final scheme = (apiUri?.scheme ?? 'http').toLowerCase() == 'https'
      ? 'wss'
      : 'ws';
  final path = '/api/v1/messages/ws/$selfId';

  if (scheme == 'wss') {
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
    );
  }

  return Uri(
    scheme: scheme,
    host: host,
    port: 8081,
    path: path,
  );
}

MessageDto? decodeChatSocketEvent(
  dynamic event, {
  required int selfId,
  required int peerId,
}) {
  final payload = switch (event) {
    final String value => value,
    final List<int> bytes => utf8.decode(bytes),
    _ => event.toString(),
  };
  if (payload.trim().isEmpty) return null;

  Map<String, dynamic>? json;
  try {
    final decoded = jsonDecode(payload);
    if (decoded is Map<String, dynamic>) {
      json = decoded;
    }
  } catch (_) {
    return null;
  }
  if (json == null) return null;

  final type = (json['type'] ?? '').toString();
  if (type != 'message') return null;

  final senderId = (json['sender_id'] as num?)?.toInt() ?? 0;
  final receiverId = (json['receiver_id'] as num?)?.toInt() ?? 0;
  final isConversationPair =
      (senderId == peerId && receiverId == selfId) ||
      (senderId == selfId && receiverId == peerId);
  if (!isConversationPair) return null;

  return MessageDto(
    id: (json['id'] ?? '').toString(),
    mine: senderId == selfId,
    text: (json['content'] ?? '').toString(),
    time: (json['created_at'] ?? '').toString(),
    attachments: const [],
  );
}

class ChatSocketDataSource {
  ChatSocketDataSource({
    required this.apiClient,
    required this.localStorage,
    required this.env,
  });

  final ApiClient apiClient;
  final LocalStorageService localStorage;
  final AppEnv env;

  Stream<MessageDto> observe(String conversationId) {
    if (env.useMockChat) {
      return const Stream.empty();
    }
    final peerId = int.tryParse(conversationId);
    if (peerId == null || peerId <= 0) {
      return const Stream.empty();
    }
    final controller = StreamController<MessageDto>.broadcast();
    var started = false;
    controller.onListen = () {
      if (started) return;
      started = true;
      unawaited(
        _runConnectionLoop(
          peerId: peerId,
          controller: controller,
        ),
      );
    };
    return controller.stream;
  }

  Future<void> _runConnectionLoop({
    required int peerId,
    required StreamController<MessageDto> controller,
  }) async {
    final selfId = await _selfId();
    if (selfId <= 0) {
      if (!controller.isClosed) {
        await controller.close();
      }
      return;
    }

    var keepRunning = true;
    controller.onCancel = () async {
      keepRunning = false;
    };

    while (keepRunning && !controller.isClosed) {
      WebSocket? socket;
      try {
        final uri = buildChatSocketUri(apiBaseUrl: env.apiBaseUrl, selfId: selfId);
        socket = await WebSocket.connect(uri.toString());
        socket.pingInterval = const Duration(seconds: 20);
        final completed = Completer<void>();
        socket.listen(
          (event) {
            final dto = decodeChatSocketEvent(event, selfId: selfId, peerId: peerId);
            if (dto != null && !controller.isClosed) {
              controller.add(dto);
            }
          },
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
            if (!completed.isCompleted) completed.complete();
          },
          onDone: () {
            if (!completed.isCompleted) completed.complete();
          },
          cancelOnError: false,
        );
        await completed.future;
      } catch (e, st) {
        if (!controller.isClosed) {
          controller.addError(e, st);
        }
      } finally {
        try {
          await socket?.close();
        } catch (_) {}
      }

      if (keepRunning && !controller.isClosed) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    if (!controller.isClosed) {
      await controller.close();
    }
  }

  Future<int> _selfId() async {
    try {
      final local = await localStorage.getJson(CacheKeys.lastKnownProfile);
      final localId = (local?['id'] as num?)?.toInt();
      if (localId != null && localId > 0) {
        return localId;
      }
    } catch (_) {}

    try {
      final profile = await apiClient.get('/api/v1/profile/basic');
      if (profile is NetworkSuccess<Map<String, dynamic>>) {
        return (profile.data['id'] as num?)?.toInt() ?? 0;
      }
    } catch (_) {}

    return 0;
  }
}
