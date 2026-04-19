import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/auth/data/datasource/auth_local_data_source.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_elitesync_module/features/auth/domain/entities/auth_user.dart';

class _InMemoryLocalStorageService extends LocalStorageService {
  _InMemoryLocalStorageService([Map<String, Object?>? initialValues]) {
    if (initialValues != null) {
      _values.addAll(initialValues);
    }
  }

  final Map<String, Object?> _values = {};

  @override
  Future<bool> setString(String key, String value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<String?> getString(String key) async {
    final value = _values[key];
    return value is String ? value : null;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<bool?> getBool(String key) async {
    final value = _values[key];
    return value is bool ? value : null;
  }

  @override
  Future<bool> setInt(String key, int value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<int?> getInt(String key) async {
    final value = _values[key];
    return value is int ? value : null;
  }

  @override
  Future<bool> remove(String key) async {
    _values.remove(key);
    return true;
  }

  @override
  Future<bool> clear() async {
    _values.clear();
    return true;
  }

  bool contains(String key) => _values.containsKey(key);
}

class _InMemorySecureStorageService extends SecureStorageService {
  _InMemorySecureStorageService();

  final Map<String, String> _values = {};

  @override
  Future<void> write(String key, String value) async {
    _values[key] = value;
  }

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async {
    _values.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _values.clear();
  }
}

void main() {
  test('persistSession clears previous account scoped caches', () async {
    final secure = _InMemorySecureStorageService();
    final local = _InMemoryLocalStorageService({
      CacheKeys.lastKnownProfile: {
        'id': 8,
        'phone': '90',
        'nickname': 'SmokeUser',
      },
      CacheKeys.profileSummarySnapshot: {'nickname': 'SmokeUser'},
      CacheKeys.profileDetailSnapshot: {'nickname': 'SmokeUser'},
      CacheKeys.matchResultSnapshot: {'partner_nickname': 'SmokeUser'},
      CacheKeys.matchDetailSnapshot: {'partner_nickname': 'SmokeUser'},
      CacheKeys.questionnaireProfileSnapshot: {'nickname': 'SmokeUser'},
      CacheKeys.messagesConversationSnapshot: '[]',
      CacheKeys.homeFeedSnapshot: '[]',
      CacheKeys.discoverFeedSnapshot: '[]',
      CacheKeys.homeSearchHistory: '[]',
      CacheKeys.discoverSearchHistory: '[]',
      CacheKeys.homeSelectedTab: 1,
      CacheKeys.discoverSelectedTab: 1,
      CacheKeys.homeSearchQuery: 'old',
      CacheKeys.discoverSearchQuery: 'old',
      CacheKeys.chatDraftPrefix: 'draft',
    });
    final dataSource = AuthLocalDataSource(
      secureStorage: secure,
      localStorage: local,
    );

    await dataSource.persistSession(
      const AuthSession(
        accessToken: 'token-new',
        refreshToken: 'refresh-new',
        user: AuthUser(id: 37, phone: '13772423130', nickname: 'test1'),
      ),
    );

    expect(await secure.read(CacheKeys.accessToken), 'token-new');
    expect(await secure.read(CacheKeys.refreshToken), 'refresh-new');
    expect(local.contains(CacheKeys.lastKnownProfile), isTrue);
    expect(local.contains(CacheKeys.profileSummarySnapshot), isFalse);
    expect(local.contains(CacheKeys.profileDetailSnapshot), isFalse);
    expect(local.contains(CacheKeys.matchResultSnapshot), isFalse);
    expect(local.contains(CacheKeys.matchDetailSnapshot), isFalse);
    expect(local.contains(CacheKeys.questionnaireProfileSnapshot), isFalse);
    expect(local.contains(CacheKeys.messagesConversationSnapshot), isFalse);
    expect(local.contains(CacheKeys.homeFeedSnapshot), isFalse);
    expect(local.contains(CacheKeys.discoverFeedSnapshot), isFalse);
    expect(local.contains(CacheKeys.homeSearchHistory), isFalse);
    expect(local.contains(CacheKeys.discoverSearchHistory), isFalse);
    expect(local.contains(CacheKeys.homeSelectedTab), isFalse);
    expect(local.contains(CacheKeys.discoverSelectedTab), isFalse);
    expect(local.contains(CacheKeys.homeSearchQuery), isFalse);
    expect(local.contains(CacheKeys.discoverSearchQuery), isFalse);
  });
}
