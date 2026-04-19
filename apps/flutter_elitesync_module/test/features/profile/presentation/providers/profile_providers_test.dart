import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/core/storage/secure_storage_service.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/birth_place_suggestion_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_detail_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';
import 'package:flutter_elitesync_module/features/profile/domain/repository/profile_repository.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/shared/models/user_summary.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<void> setJsonValue(String key, Map<String, dynamic> value) async {
    await setString(key, value.toString());
  }
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
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository({
    required ProfileSummaryEntity summary,
    required ProfileDetailEntity detail,
  }) : _summary = summary,
       _detail = detail;

  ProfileSummaryEntity _summary;
  ProfileDetailEntity _detail;

  set summary(ProfileSummaryEntity value) => _summary = value;
  set detail(ProfileDetailEntity value) => _detail = value;

  @override
  Future<ProfileDetailEntity> getDetail() async => _detail;

  @override
  Future<ProfileSummaryEntity> getSummary() async => _summary;

  @override
  Future<Map<String, dynamic>> update(ProfileDetailEntity detail) async => {
    'user': {
      'nickname': detail.nickname,
      'gender': detail.gender,
      'birthday': detail.birthday,
      'birth_time': detail.birthTime,
      'city': detail.city,
      'target': detail.target,
      'birth_place': detail.birthPlace,
      'birth_lat': detail.birthLat,
      'birth_lng': detail.birthLng,
    },
  };

  @override
  Future<List<BirthPlaceSuggestionEntity>> searchBirthPlaces({
    required String query,
    String region = '全国',
  }) async => const [];
}

void main() {
  test(
    'profileProvider refreshes after session switch instead of reusing old nickname cache',
    () async {
      final secure = _InMemorySecureStorageService();
      final local = _InMemoryLocalStorageService();
      final repo = _FakeProfileRepository(
        summary: const ProfileSummaryEntity(
          nickname: 'OldNick',
          birthday: '1990-01-01',
          birthTime: '12:00',
          birthPlace: null,
          city: 'OldCity',
          target: 'dating',
          verified: false,
          moderationStatus: 'normal',
          moderationNote: null,
          completion: 1,
          tags: ['旧账号'],
        ),
        detail: const ProfileDetailEntity(
          nickname: 'OldNick',
          gender: 'female',
          birthday: '1990-01-01',
          birthTime: '12:00',
          city: 'OldCity',
          target: 'dating',
        ),
      );
      await secure.write(CacheKeys.accessToken, 'token-old');
      await secure.write(CacheKeys.refreshToken, 'refresh-old');
      await local.setJson(CacheKeys.lastKnownProfile, {
        'id': 8,
        'phone': '90',
        'nickname': 'OldNick',
        'name': 'OldNick',
        'birthday': '1990-01-01',
        'birth_time': '12:00',
        'city': 'OldCity',
        'relationship_goal': 'dating',
        'target': 'dating',
      });
      await local.setJson(CacheKeys.profileSummarySnapshot, {
        'nickname': 'OldNick',
        'birthday': '1990-01-01',
        'birth_time': '12:00',
        'city': 'OldCity',
        'target': 'dating',
        'verified': false,
        'moderation_status': 'normal',
        'completion': 1,
        'tags': ['旧账号'],
      });

      final container = ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(secure),
          localStorageProvider.overrideWithValue(local),
          profileRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final before = await container.read(profileProvider.future);
      expect(before.summary?.nickname, 'OldNick');

      repo.summary = const ProfileSummaryEntity(
        nickname: 'test1',
        birthday: '1995-05-05',
        birthTime: '10:10',
        birthPlace: null,
        city: 'NewCity',
        target: 'dating',
        verified: true,
        moderationStatus: 'normal',
        moderationNote: null,
        completion: 1,
        tags: ['新账号'],
      );
      repo.detail = const ProfileDetailEntity(
        nickname: 'test1',
        gender: 'male',
        birthday: '1995-05-05',
        birthTime: '10:10',
        city: 'NewCity',
        target: 'dating',
      );

      await container
          .read(sessionProvider.notifier)
          .setAuthenticated(
            accessToken: 'token-new',
            refreshToken: 'refresh-new',
            user: const UserSummary(
              id: 37,
              phone: '13772423130',
              nickname: 'test1',
              birthday: '1995-05-05',
              birthTime: '10:10',
              city: 'NewCity',
              relationshipGoal: 'dating',
              verified: true,
            ),
          );

      final after = await container.read(profileProvider.future);
      expect(after.summary?.nickname, 'test1');
      expect(
        (await local.getJson(CacheKeys.profileSummarySnapshot))?['nickname'],
        'test1',
      );
    },
  );
}
