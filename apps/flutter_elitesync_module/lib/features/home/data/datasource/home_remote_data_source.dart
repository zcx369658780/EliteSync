import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/core/storage/local_storage_service.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/home_mock.dart';
import 'package:flutter_elitesync_module/features/home/data/dto/home_banner_dto.dart';
import 'package:flutter_elitesync_module/features/home/data/dto/home_feed_dto.dart';
import 'package:flutter_elitesync_module/features/home/data/dto/shortcut_entry_dto.dart';

class FeedPageResult {
  const FeedPageResult({
    required this.items,
    this.nextCursor,
    this.hasMore = false,
  });

  final List<HomeFeedDto> items;
  final String? nextCursor;
  final bool hasMore;
}

class HomeRemoteDataSource {
  HomeRemoteDataSource({
    required this.apiClient,
    required this.useMock,
    required this.localStorage,
  });

  final ApiClient apiClient;
  final bool useMock;
  final LocalStorageService localStorage;

  Future<String> _rankerMode() async {
    final mode = (await localStorage.getString(CacheKeys.contentRankerMode))?.trim().toLowerCase() ?? 'auto';
    if (mode == 'legacy' || mode == 'weighted' || mode == 'auto') return mode;
    return 'auto';
  }

  Future<String?> _preferredTag() async {
    final tag = (await localStorage.getString(CacheKeys.contentPreferredTag))?.trim() ?? '';
    return tag.isEmpty ? null : tag;
  }

  Future<(String?, String?)> _preferredTagPair() async {
    // Preferred path via persisted tag-score map.
    final map = await localStorage.getJson(CacheKeys.contentPreferredTagsMap);
    if (map != null && map.isNotEmpty) {
      final ranked = map.entries
          .where((e) => e.key.trim().isNotEmpty)
          .map((e) => MapEntry(e.key.trim(), (e.value as num?)?.toInt() ?? 0))
          .where((e) => e.value > 0)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      if (ranked.isNotEmpty) {
        final primary = ranked.first.key;
        final secondary = ranked.length > 1 ? ranked[1].key : null;
        return (primary, secondary);
      }
    }

    // Legacy fallback: single preferred tag.
    final single = await _preferredTag();
    return (single, null);
  }

  Future<HomeBannerDto> fetchBanner() async {
    if (useMock) {
      return HomeBannerDto.fromJson(HomeMock.hero);
    }
    try {
      final result = await apiClient.get('/api/v1/home/banner');
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        return HomeBannerDto.fromJson(result.data['data'] as Map<String, dynamic>? ?? {});
      }
      final failure = result as NetworkFailure<Map<String, dynamic>>;
      throw Exception(failure.message);
    } catch (_) {
      return HomeBannerDto.fromJson(HomeMock.hero);
    }
  }

  Future<List<ShortcutEntryDto>> fetchShortcuts() async {
    if (useMock) {
      return HomeMock.shortcuts.map(ShortcutEntryDto.fromJson).toList();
    }
    try {
      final result = await apiClient.get('/api/v1/home/shortcuts');
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final list = (result.data['data'] as List<dynamic>? ?? const []);
        return list.whereType<Map<String, dynamic>>().map(ShortcutEntryDto.fromJson).toList();
      }
      final failure = result as NetworkFailure<Map<String, dynamic>>;
      throw Exception(failure.message);
    } catch (_) {
      return HomeMock.shortcuts.map(ShortcutEntryDto.fromJson).toList();
    }
  }

  Future<List<HomeFeedDto>> fetchFeed() async {
    final page = await fetchFeedPage();
    return page.items;
  }

  Future<List<HomeFeedDto>> fetchDiscoverFeed({String? tab}) async {
    final page = await fetchDiscoverFeedPage(tab: tab);
    return page.items;
  }

  Future<FeedPageResult> fetchFeedPage({
    String? tab,
    String? cursor,
    int limit = 12,
  }) async {
    if (useMock) {
      final all = HomeMock.feedHappy.map(HomeFeedDto.fromJson).toList();
      final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
      final end = (start + limit) > all.length ? all.length : (start + limit);
      final slice = all.sublist(start, end);
      final hasMore = end < all.length;
      return FeedPageResult(
        items: slice,
        nextCursor: hasMore ? end.toString() : null,
        hasMore: hasMore,
      );
    }
    try {
      final ranker = await _rankerMode();
      final (preferredTag, preferredTag2) = await _preferredTagPair();
      final query = <String, dynamic>{'limit': limit};
      if ((tab ?? '').isNotEmpty) query['tab'] = tab;
      if ((cursor ?? '').isNotEmpty) query['cursor'] = cursor;
      query['ranker'] = ranker;
      if ((preferredTag ?? '').isNotEmpty) query['boost_tag'] = preferredTag;
      if ((preferredTag2 ?? '').isNotEmpty) query['boost_tag_secondary'] = preferredTag2;
      final result = await apiClient.get('/api/v1/home/feed', query: query);
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final list = (result.data['data'] as List<dynamic>? ?? const []);
        final items = list.whereType<Map<String, dynamic>>().map(HomeFeedDto.fromJson).toList();
        final meta = result.data['meta'] as Map<String, dynamic>?;
        final nextCursor = (meta?['next_cursor'] ?? meta?['next'])?.toString();
        final hasMore = (meta?['has_more'] as bool?) ?? (nextCursor != null && nextCursor.isNotEmpty);
        return FeedPageResult(items: items, nextCursor: nextCursor, hasMore: hasMore);
      }
      final failure = result as NetworkFailure<Map<String, dynamic>>;
      throw Exception(failure.message);
    } catch (_) {
      final all = HomeMock.feedHappy.map(HomeFeedDto.fromJson).toList();
      final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
      final end = (start + limit) > all.length ? all.length : (start + limit);
      final slice = all.sublist(start, end);
      final hasMore = end < all.length;
      return FeedPageResult(
        items: slice,
        nextCursor: hasMore ? end.toString() : null,
        hasMore: hasMore,
      );
    }
  }

  Future<FeedPageResult> fetchDiscoverFeedPage({
    String? tab,
    String? cursor,
    int limit = 12,
  }) async {
    if (useMock) {
      final all = HomeMock.discoverFeed.map(HomeFeedDto.fromJson).toList();
      final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
      final end = (start + limit) > all.length ? all.length : (start + limit);
      final slice = all.sublist(start, end);
      final hasMore = end < all.length;
      return FeedPageResult(
        items: slice,
        nextCursor: hasMore ? end.toString() : null,
        hasMore: hasMore,
      );
    }
    try {
      final ranker = await _rankerMode();
      final (preferredTag, preferredTag2) = await _preferredTagPair();
      final query = <String, dynamic>{'limit': limit};
      if ((tab ?? '').isNotEmpty) {
        query['tab'] = tab;
      }
      if ((cursor ?? '').isNotEmpty) {
        query['cursor'] = cursor;
      }
      query['ranker'] = ranker;
      if ((preferredTag ?? '').isNotEmpty) query['boost_tag'] = preferredTag;
      if ((preferredTag2 ?? '').isNotEmpty) query['boost_tag_secondary'] = preferredTag2;
      final primary = await apiClient.get('/api/v1/discover/feed', query: query.isEmpty ? null : query);
      if (primary is NetworkSuccess<Map<String, dynamic>>) {
        final list = (primary.data['data'] as List<dynamic>? ?? const []);
        if (list.isNotEmpty) {
          final items = list.whereType<Map<String, dynamic>>().map(HomeFeedDto.fromJson).toList();
          final meta = primary.data['meta'] as Map<String, dynamic>?;
          final nextCursor = (meta?['next_cursor'] ?? meta?['next'])?.toString();
          final hasMore = (meta?['has_more'] as bool?) ?? (nextCursor != null && nextCursor.isNotEmpty);
          return FeedPageResult(items: items, nextCursor: nextCursor, hasMore: hasMore);
        }
      }
      final fallbackQuery = <String, dynamic>{'scene': 'discover'};
      if ((tab ?? '').isNotEmpty) {
        fallbackQuery['tab'] = tab;
      }
      if ((cursor ?? '').isNotEmpty) {
        fallbackQuery['cursor'] = cursor;
      }
      fallbackQuery['limit'] = limit;
      fallbackQuery['ranker'] = ranker;
      if ((preferredTag ?? '').isNotEmpty) fallbackQuery['boost_tag'] = preferredTag;
      if ((preferredTag2 ?? '').isNotEmpty) fallbackQuery['boost_tag_secondary'] = preferredTag2;
      final fallback = await apiClient.get('/api/v1/home/feed', query: fallbackQuery);
      if (fallback is NetworkSuccess<Map<String, dynamic>>) {
        final list = (fallback.data['data'] as List<dynamic>? ?? const []);
        if (list.isNotEmpty) {
          final items = list.whereType<Map<String, dynamic>>().map(HomeFeedDto.fromJson).toList();
          final meta = fallback.data['meta'] as Map<String, dynamic>?;
          final nextCursor = (meta?['next_cursor'] ?? meta?['next'])?.toString();
          final hasMore = (meta?['has_more'] as bool?) ?? (nextCursor != null && nextCursor.isNotEmpty);
          return FeedPageResult(items: items, nextCursor: nextCursor, hasMore: hasMore);
        }
      }
      final all = HomeMock.discoverFeed.map(HomeFeedDto.fromJson).toList();
      final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
      final end = (start + limit) > all.length ? all.length : (start + limit);
      final slice = all.sublist(start, end);
      final hasMore = end < all.length;
      return FeedPageResult(
        items: slice,
        nextCursor: hasMore ? end.toString() : null,
        hasMore: hasMore,
      );
    } catch (_) {
      final all = HomeMock.discoverFeed.map(HomeFeedDto.fromJson).toList();
      final start = cursor == null ? 0 : int.tryParse(cursor) ?? 0;
      final end = (start + limit) > all.length ? all.length : (start + limit);
      final slice = all.sublist(start, end);
      final hasMore = end < all.length;
      return FeedPageResult(
        items: slice,
        nextCursor: hasMore ? end.toString() : null,
        hasMore: hasMore,
      );
    }
  }

  Future<HomeFeedDto> fetchContentDetail(String contentId) async {
    HomeFeedDto fallback() {
      final all = [...HomeMock.feedHappy, ...HomeMock.discoverFeed];
      for (final item in all) {
        if (item['id']?.toString() == contentId) {
          return HomeFeedDto.fromJson(Map<String, dynamic>.from(item));
        }
      }
      return HomeFeedDto(
        id: contentId,
        title: '内容详情',
        summary: '该内容正在完善中，稍后将展示完整正文与互动信息。',
        author: '系统',
        likes: 0,
      );
    }

    if (useMock) {
      return fallback();
    }
    try {
      final result = await apiClient.get('/api/v1/content/$contentId');
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final data = result.data['data'] as Map<String, dynamic>?;
        if (data != null && data.isNotEmpty) {
          return HomeFeedDto.fromJson(data);
        }
      }
      return fallback();
    } catch (_) {
      return fallback();
    }
  }
}
