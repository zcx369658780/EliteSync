import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/data/mapper/match_mapper.dart';
import 'package:flutter_elitesync_module/features/match/data/repository/match_repository_impl.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/repository/match_repository.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_countdown_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_match_result_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_match_detail_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/submit_intention_usecase.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_countdown_ui_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final matchRemoteDataSourceProvider = Provider<MatchRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return MatchRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockMatch);
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepositoryImpl(remote: ref.watch(matchRemoteDataSourceProvider), mapper: const MatchMapper());
});

final getCountdownUseCaseProvider = Provider<GetCountdownUseCase>((ref) => GetCountdownUseCase(ref.watch(matchRepositoryProvider)));
final getMatchResultUseCaseProvider = Provider<GetMatchResultUseCase>((ref) => GetMatchResultUseCase(ref.watch(matchRepositoryProvider)));
final getMatchDetailUseCaseProvider = Provider<GetMatchDetailUseCase>((ref) => GetMatchDetailUseCase(ref.watch(matchRepositoryProvider)));
final submitIntentionUseCaseProvider = Provider<SubmitIntentionUseCase>((ref) => SubmitIntentionUseCase(ref.watch(matchRepositoryProvider)));

Map<String, dynamic> _matchResultToJson(MatchResultEntity entity) => {
  'headline': entity.headline,
  'score': entity.score,
  'tags': entity.tags,
  'highlights': entity.highlights
      .map((e) => {'title': e.title, 'value': e.value, 'desc': e.desc})
      .toList(),
};

MatchResultEntity? _matchResultFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  final highlights = (json['highlights'] as List<dynamic>? ?? const [])
      .map((e) {
        if (e is Map) {
          return MatchHighlightEntity(
            title: (e['title'] ?? '').toString(),
            value: (e['value'] as num?)?.toInt() ?? 0,
            desc: (e['desc'] ?? '').toString(),
          );
        }
        return MatchHighlightEntity(title: '', value: 0, desc: '');
      })
      .where((e) => e.title.isNotEmpty || e.desc.isNotEmpty)
      .toList();
  return MatchResultEntity(
    headline: (json['headline'] ?? '').toString(),
    score: (json['score'] as num?)?.toInt() ?? 0,
    tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    highlights: highlights,
  );
}

Map<String, dynamic> _matchDetailToJson(MatchDetailEntity entity) => {
  'reasons': entity.reasons,
  'weights': entity.weights,
  'moduleScores': entity.moduleScores,
  'moduleInsights': entity.moduleInsights,
  'moduleExplanations': entity.moduleExplanations,
  'explanationBlocks': entity.explanationBlocks,
  'compatibilitySections': entity.compatibilitySections.map(
    (key, value) => MapEntry(key, value),
  ),
  'reasonGlossary': entity.reasonGlossary,
  'evidenceStrengthSummary': entity.evidenceStrengthSummary,
};

MatchDetailEntity? _matchDetailFromJson(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;
  final compat = <String, List<Map<String, dynamic>>>{};
  final rawCompat = json['compatibilitySections'];
  if (rawCompat is Map) {
    rawCompat.forEach((key, value) {
      final rows = <Map<String, dynamic>>[];
      if (value is List) {
        for (final item in value) {
          if (item is Map) {
            rows.add(item.map((k, v) => MapEntry(k.toString(), v)));
          }
        }
      }
      compat[key.toString()] = rows;
    });
  }
  List<Map<String, dynamic>> toMapList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }
  Map<String, int> toIntMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map(
      (k, v) => MapEntry(k.toString(), (v as num?)?.toInt() ?? 0),
    );
  }
  Map<String, String> toStringMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(k.toString(), v.toString()));
  }
  Map<String, dynamic> toDynamicMap(dynamic raw) {
    if (raw is! Map) return const {};
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }
  return MatchDetailEntity(
    reasons: (json['reasons'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    weights: toIntMap(json['weights']),
    moduleScores: toIntMap(json['moduleScores']),
    moduleInsights: (json['moduleInsights'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
    moduleExplanations: toMapList(json['moduleExplanations']),
    explanationBlocks: toMapList(json['explanationBlocks']),
    compatibilitySections: compat,
    reasonGlossary: toStringMap(json['reasonGlossary']),
    evidenceStrengthSummary: toDynamicMap(json['evidenceStrengthSummary']),
  );
}

final matchCountdownProvider = FutureProvider<MatchCountdownUiState>((ref) async {
  try {
    final data = await ref.read(getCountdownUseCaseProvider).call();
    return MatchCountdownUiState(data: data);
  } catch (e) {
    return MatchCountdownUiState(error: e.toString());
  }
});

final matchResultProvider = FutureProvider<MatchResultUiState>((ref) async {
  final local = ref.read(localStorageProvider);
  try {
    final data = await ref.read(getMatchResultUseCaseProvider).call();
    await local.setJson(CacheKeys.matchResultSnapshot, _matchResultToJson(data));
    return MatchResultUiState(data: data);
  } catch (e) {
    final cached = await local.getJson(CacheKeys.matchResultSnapshot);
    return MatchResultUiState(data: _matchResultFromJson(cached), error: e.toString());
  }
});

final matchDetailProvider = FutureProvider<MatchDetailEntity>((ref) async {
  final local = ref.read(localStorageProvider);
  try {
    final data = await ref.read(getMatchDetailUseCaseProvider).call();
    await local.setJson(CacheKeys.matchDetailSnapshot, _matchDetailToJson(data));
    return data;
  } catch (_) {
    final cached = await local.getJson(CacheKeys.matchDetailSnapshot);
    final data = _matchDetailFromJson(cached);
    if (data != null) return data;
    rethrow;
  }
});
