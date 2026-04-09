import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/telemetry/app_telemetry_service.dart';

class FrontendTelemetry {
  const FrontendTelemetry({required this.telemetry});

  final AppTelemetryService telemetry;

  Future<void> _trackEvent(
    String path, {
    required String eventName,
    required String sourcePage,
    int? targetUserId,
    int? matchId,
    Map<String, dynamic> payload = const {},
  }) async {
    final body = <String, dynamic>{
      'event_name': eventName,
      ...?targetUserId == null
          ? null
          : <String, dynamic>{'target_user_id': targetUserId},
      ...?matchId == null ? null : <String, dynamic>{'match_id': matchId},
      ...?payload.isEmpty ? null : <String, dynamic>{'payload': payload},
    };
    try {
      final result = await telemetry.postEvent(
        path,
        sourcePage: sourcePage,
        body: body,
      );
      if (result is NetworkFailure<Map<String, dynamic>>) {
        return;
      }
    } catch (_) {
      return;
    }
  }

  void matchExplanationEntry({
    required int targetUserId,
    required String sourcePage,
    int? matchId,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/match-explanation-preview-opened',
        eventName: 'match_explanation_preview_opened',
        sourcePage: sourcePage,
        targetUserId: targetUserId,
        matchId: matchId,
        payload: const <String, dynamic>{'surface': 'match_result'},
      ),
    );
  }

  void firstChatEntry({
    required int targetUserId,
    required String sourcePage,
    int? matchId,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/first-chat-entry',
        eventName: 'match_first_chat_entry',
        sourcePage: sourcePage,
        targetUserId: targetUserId,
        matchId: matchId,
        payload: const <String, dynamic>{'surface': 'match_result'},
      ),
    );
  }

  void matchFeedbackSubmitted({
    required String sourcePage,
    int? targetUserId,
    int? matchId,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/match-feedback-submitted',
        eventName: 'match_feedback_submitted',
        sourcePage: sourcePage,
        targetUserId: targetUserId,
        matchId: matchId,
        payload: const <String, dynamic>{'surface': 'match_feedback'},
      ),
    );
  }
}

final frontendTelemetryProvider = Provider<FrontendTelemetry>((ref) {
  return FrontendTelemetry(telemetry: ref.watch(appTelemetryProvider));
});
