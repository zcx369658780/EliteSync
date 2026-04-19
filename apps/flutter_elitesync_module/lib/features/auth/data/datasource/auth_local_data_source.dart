import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';

class AuthLocalDataSource {
  const AuthLocalDataSource({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) : _secureStorage = secureStorage,
       _localStorage = localStorage;

  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  Future<void> persistSession(AuthSession session) async {
    await _secureStorage.write(CacheKeys.accessToken, session.accessToken);
    await _secureStorage.write(CacheKeys.refreshToken, session.refreshToken);
    await _clearAccountScopedCaches();
    await _localStorage.setJson(CacheKeys.lastKnownProfile, {
      'id': session.user.id,
      'phone': session.user.phone,
      'nickname': session.user.nickname,
      'name': session.user.nickname,
      'birthday': session.user.birthday,
      'birth_time': session.user.birthTime,
      'gender': session.user.gender,
      'city': session.user.city,
      'relationship_goal': session.user.relationshipGoal,
      'target': session.user.relationshipGoal,
      'birth_place': session.user.birthPlace,
      'birth_lat': session.user.birthLat,
      'birth_lng': session.user.birthLng,
      'avatar_url': session.user.avatarUrl,
      'verified': session.user.verified,
      'realname_verified': session.user.verified,
    });
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(CacheKeys.accessToken);
    await _secureStorage.delete(CacheKeys.refreshToken);
    await _clearAccountScopedCaches();
  }

  Future<void> _clearAccountScopedCaches() async {
    await _localStorage.remove(CacheKeys.lastKnownProfile);
    await _localStorage.remove(CacheKeys.profileSummarySnapshot);
    await _localStorage.remove(CacheKeys.profileDetailSnapshot);
    await _localStorage.remove(CacheKeys.matchResultSnapshot);
    await _localStorage.remove(CacheKeys.matchDetailSnapshot);
    await _localStorage.remove(CacheKeys.questionnaireProfileSnapshot);
    await _localStorage.remove(CacheKeys.questionnaireDraft);
    await _localStorage.remove(CacheKeys.messagesConversationSnapshot);
    await _localStorage.remove(CacheKeys.messagesSearchHistory);
    await _localStorage.remove(CacheKeys.messagesSelectedTab);
    await _localStorage.remove(CacheKeys.messagesQuickUnreadOnly);
    await _localStorage.remove(CacheKeys.homeFeedSnapshot);
    await _localStorage.remove(CacheKeys.discoverFeedSnapshot);
    await _localStorage.remove(CacheKeys.homeSearchHistory);
    await _localStorage.remove(CacheKeys.discoverSearchHistory);
    await _localStorage.remove(CacheKeys.homeSelectedTab);
    await _localStorage.remove(CacheKeys.discoverSelectedTab);
    await _localStorage.remove(CacheKeys.homeSearchQuery);
    await _localStorage.remove(CacheKeys.discoverSearchQuery);
    await _localStorage.remove(CacheKeys.chatDraftPrefix);
  }
}
