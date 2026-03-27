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
}
