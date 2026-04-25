abstract final class CacheKeys {
  // Sensitive keys (secure storage)
  static const accessToken = 'auth_access_token';
  static const refreshToken = 'auth_refresh_token';
  static const tokenExpireAt = 'auth_token_expire_at';

  // Non-sensitive keys (shared preferences)
  static const onboardingDone = 'onboarding_done';
  static const questionnaireDraft = 'questionnaire_draft';
  static const appThemeMode = 'app_theme_mode';
  static const lastKnownProfile = 'last_known_profile';
  static const featureFlags = 'feature_flags';
  static const pushNotificationEnabled = 'push_notification_enabled';
  static const privacyProfileVisible = 'privacy_profile_visible';
  static const privacyShowCity = 'privacy_show_city';
  static const performanceLiteMode = 'performance_lite_mode';
  static const contentRankerMode = 'content_ranker_mode';
  static const contentPreferredTag = 'content_preferred_tag';
  static const contentPreferredTagsMap = 'content_preferred_tags_map_v1';
  static const profileSummarySnapshot = 'profile_summary_snapshot_v1';
  static const profileDetailSnapshot = 'profile_detail_snapshot_v1';
  static const questionnaireProfileSnapshot =
      'questionnaire_profile_snapshot_v1';
  static const matchResultSnapshot = 'match_result_snapshot_v1';
  static const matchDetailSnapshot = 'match_detail_snapshot_v1';
  static const matchFeedbackHistory = 'match_feedback_history_v1';
  static const astroChartPreferences = 'astro_chart_preferences_v1';
  static const astroChartRoutePreferences = 'astro_chart_route_preferences_v1';
  static const astroChartWorkbenchPreferences =
      'astro_chart_workbench_preferences_v1';
  static const homeSearchQuery = 'home_search_query';
  static const discoverSearchQuery = 'discover_search_query';
  static const messagesSearchQuery = 'messages_search_query';
  static const homeSearchHistory = 'home_search_history';
  static const homeSelectedTab = 'home_selected_tab';
  static const discoverSearchHistory = 'discover_search_history';
  static const messagesSearchHistory = 'messages_search_history';
  static const discoverSelectedTab = 'discover_selected_tab';
  static const messagesSelectedTab = 'messages_selected_tab';
  static const messagesQuickUnreadOnly = 'messages_quick_unread_only';
  static const homeFeedSnapshot = 'home_feed_snapshot_v1';
  static const discoverFeedSnapshot = 'discover_feed_snapshot_v1';
  static const chatDraftPrefix = 'chat_draft_';
  static const messagesConversationSnapshot =
      'messages_conversation_snapshot_v1';
  static const rtcAutoInviteHandledCallId = 'rtc_auto_invite_handled_call_id';
  static const rtcAutoInviteHandledNotificationId =
      'rtc_auto_invite_handled_notification_id';
}
