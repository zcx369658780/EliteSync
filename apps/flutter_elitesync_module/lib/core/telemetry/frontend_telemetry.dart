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

  void questionnaireSummaryHistoryOpened({required String sourcePage}) {
    questionnaireHistoryOpened(sourcePage: sourcePage);
  }

  void questionnaireHistoryOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'questionnaire_history_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{
          'surface': 'questionnaire_history',
          'action': 'history',
        },
      ),
    );
  }

  void questionnaireSummaryContinueTapped({required String sourcePage}) {
    questionnaireRetestStarted(sourcePage: sourcePage);
  }

  void questionnaireRetestStarted({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'questionnaire_retest_started',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{
          'surface': 'questionnaire_retest',
          'action': 'continue',
        },
      ),
    );
  }

  void questionnaireEntryOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'questionnaire_entry_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'questionnaire_entry'},
      ),
    );
  }

  void questionnaireSubmitted({
    required String sourcePage,
    String? questionnaireVersion,
    String? bankVersion,
    String? attemptVersion,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'questionnaire_submitted',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'questionnaire_result',
          if (questionnaireVersion != null)
            'questionnaire_version': questionnaireVersion,
          if (bankVersion != null) 'bank_version': bankVersion,
          if (attemptVersion != null) 'attempt_version': attemptVersion,
        },
      ),
    );
  }

  void questionnaireResultViewed({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'questionnaire_result_viewed',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'questionnaire_result'},
      ),
    );
  }

  void homepagePersonalitySummaryOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'homepage_personality_summary_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{
          'surface': 'home_questionnaire_summary',
        },
      ),
    );
  }

  void matchPersonalityHintOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'match_personality_hint_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{
          'surface': 'match_questionnaire_summary',
        },
      ),
    );
  }

  void chatImagePickerOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_image_picker_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'chat_image_picker'},
      ),
    );
  }

  void chatImageUploadStarted({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_image_upload_started',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'chat_image_upload'},
      ),
    );
  }

  void chatImageUploadSucceeded({required String sourcePage, int? assetId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_image_upload_succeeded',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_image_upload',
          if (assetId != null) 'asset_id': assetId,
        },
      ),
    );
  }

  void chatImageUploadFailed({required String sourcePage, String? errorCode}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_image_upload_failed',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_image_upload',
          if (errorCode != null) 'error_code': errorCode,
        },
      ),
    );
  }

  void chatImageMessageSent({
    required String sourcePage,
    int? attachmentCount,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_image_message_sent',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_image_message',
          if (attachmentCount != null) 'attachment_count': attachmentCount,
        },
      ),
    );
  }

  void chatVideoPickerOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_picker_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'chat_video_picker'},
      ),
    );
  }

  void chatVideoUploadStarted({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_upload_started',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'chat_video_upload'},
      ),
    );
  }

  void chatVideoUploadSucceeded({required String sourcePage, int? assetId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_upload_succeeded',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_video_upload',
          if (assetId != null) 'asset_id': assetId,
        },
      ),
    );
  }

  void chatVideoUploadFailed({required String sourcePage, String? errorCode}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_upload_failed',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_video_upload',
          if (errorCode != null) 'error_code': errorCode,
        },
      ),
    );
  }

  void chatVideoMessageSent({
    required String sourcePage,
    int? attachmentCount,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_message_sent',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'chat_video_message',
          if (attachmentCount != null) 'attachment_count': attachmentCount,
        },
      ),
    );
  }

  void chatVideoPlaybackOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'chat_video_playback_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'chat_video_playback'},
      ),
    );
  }

  void statusImagePickerOpened({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_image_picker_opened',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'status_image_picker'},
      ),
    );
  }

  void statusImageUploadStarted({required String sourcePage}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_image_upload_started',
        sourcePage: sourcePage,
        payload: const <String, dynamic>{'surface': 'status_image_upload'},
      ),
    );
  }

  void statusImageUploadSucceeded({required String sourcePage, int? assetId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_image_upload_succeeded',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_image_upload',
          if (assetId != null) 'asset_id': assetId,
        },
      ),
    );
  }

  void statusImageUploadFailed({
    required String sourcePage,
    String? errorCode,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_image_upload_failed',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_image_upload',
          if (errorCode != null) 'error_code': errorCode,
        },
      ),
    );
  }

  void statusPostPublished({required String sourcePage, int? postId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_post_published',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_post',
          if (postId != null) 'post_id': postId,
        },
      ),
    );
  }

  void statusPostLiked({
    required String sourcePage,
    int? postId,
    required bool liked,
  }) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: liked ? 'status_post_liked' : 'status_post_unliked',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_post',
          'liked': liked,
          if (postId != null) 'post_id': postId,
        },
      ),
    );
  }

  void statusPostReported({required String sourcePage, int? postId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_post_reported',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_post',
          if (postId != null) 'post_id': postId,
        },
      ),
    );
  }

  void statusAuthorOpened({required String sourcePage, int? userId}) {
    unawaited(
      _trackEvent(
        '/api/v1/telemetry/events',
        eventName: 'status_author_opened',
        sourcePage: sourcePage,
        payload: <String, dynamic>{
          'surface': 'status_author',
          if (userId != null) 'user_id': userId,
        },
      ),
    );
  }
}

final frontendTelemetryProvider = Provider<FrontendTelemetry>((ref) {
  return FrontendTelemetry(telemetry: ref.watch(appTelemetryProvider));
});
