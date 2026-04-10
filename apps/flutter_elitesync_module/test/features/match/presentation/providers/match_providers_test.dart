import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_countdown_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/repository/match_repository.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_match_result_usecase.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class InMemoryLocalStorageService extends LocalStorageService {
  InMemoryLocalStorageService([Map<String, Object?>? initialValues]) {
    _values.addAll(initialValues ?? const {});
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
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    _values[key] = value;
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getJson(String key) async {
    final value = _values[key];
    return value is Map<String, dynamic> ? value : null;
  }
}

class ThrowingMatchRepository implements MatchRepository {
  @override
  Future<MatchCountdownEntity> getCountdown() {
    throw StateError('remote unavailable');
  }

  @override
  Future<MatchDetailEntity> getDetail() {
    throw StateError('remote unavailable');
  }

  @override
  Future<MatchResultEntity> getResult() {
    throw StateError('remote unavailable');
  }

  @override
  Future<void> submitIntention(String action) {
    throw StateError('remote unavailable');
  }
}

void main() {
  test('match result provider restores ids from cached snapshot', () async {
    final container = ProviderContainer(
      overrides: [
        localStorageProvider.overrideWithValue(
          InMemoryLocalStorageService({
            CacheKeys.matchResultSnapshot: {
              'headline': '你们在沟通与情绪节奏上较契合',
              'score': 86,
              'tags': ['同城', '高匹配'],
              'match_id': 1703,
              'partner_id': 42,
              'partner_nickname': '晨雾',
              'highlights': [
                {'title': '依恋安全感', 'value': 51, 'desc': '都倾向稳定关系'},
              ],
            },
          }),
        ),
        getMatchResultUseCaseProvider.overrideWithValue(
          GetMatchResultUseCase(ThrowingMatchRepository()),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = await container.read(matchResultProvider.future);

    expect(state, isA<MatchResultUiState>());
    expect(state.data?.matchId, 1703);
    expect(state.data?.partnerId, 42);
    expect(state.data?.partnerNickname, '晨雾');
    expect(state.data?.headline, '你们在沟通与情绪节奏上较契合');
  });
}
