import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_feedback_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

List<MatchFeedbackEntity> _decodeFeedbackList(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) return const [];
  final items = raw['items'];
  if (items is! List) return const [];
  return items
      .whereType<Map>()
      .map((e) => MatchFeedbackEntity.fromJson(
            e.map((k, v) => MapEntry(k.toString(), v)),
          ))
      .toList();
}

final matchFeedbackHistoryProvider = FutureProvider<List<MatchFeedbackEntity>>((ref) async {
  final raw = await ref.read(localStorageProvider).getJson(CacheKeys.matchFeedbackHistory);
  final list = _decodeFeedbackList(raw);
  list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return list;
});

Future<void> saveMatchFeedbackEntry(WidgetRef ref, MatchFeedbackEntity entry) async {
  final local = ref.read(localStorageProvider);
  final raw = await local.getJson(CacheKeys.matchFeedbackHistory);
  final current = _decodeFeedbackList(raw);
  final next = <MatchFeedbackEntity>[entry, ...current].take(20).toList();
  await local.setJson(CacheKeys.matchFeedbackHistory, {
    'items': next.map((e) => e.toJson()).toList(),
  });
  ref.invalidate(matchFeedbackHistoryProvider);
}
