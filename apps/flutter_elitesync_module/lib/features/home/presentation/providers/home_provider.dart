import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_elitesync_module/features/home/domain/repository/home_repository.dart';
import 'package:flutter_elitesync_module/features/home/domain/usecases/fetch_home_feed_usecase.dart';
import 'package:flutter_elitesync_module/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return HomeRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockHome);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepositoryImpl(remote: ref.watch(homeRemoteDataSourceProvider), mapper: const HomeMapper());
});

final fetchHomeFeedUseCaseProvider = Provider<FetchHomeFeedUseCase>((ref) {
  return FetchHomeFeedUseCase(ref.watch(homeRepositoryProvider));
});

class HomeNotifier extends AsyncNotifier<HomeUiState> {
  @override
  Future<HomeUiState> build() async {
    final cached = await _readSnapshot();
    if (cached != null) {
      // Instant paint from local snapshot, then refresh in background.
      Future.microtask(refresh);
      return cached;
    }
    final bundle = await ref.read(fetchHomeFeedUseCaseProvider).call();
    const initialTab = 'recommend';
    final page = await ref.read(homeRemoteDataSourceProvider).fetchFeedPage(
          tab: initialTab,
          limit: 12,
        );
    final mapper = const HomeMapper();
    final nextState = HomeUiState(
      banner: bundle.banner,
      shortcuts: bundle.shortcuts,
      feed: page.items.map(mapper.feed).toList(),
      currentTab: initialTab,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
    await _writeSnapshot(nextState);
    return nextState;
  }

  Future<void> refresh() async {
    final current = state.asData?.value ?? const HomeUiState();
    state = AsyncData(current.copyWith(isRefreshing: true, clearError: true));
    try {
      final bundle = await ref.read(fetchHomeFeedUseCaseProvider).call();
      final page = await ref.read(homeRemoteDataSourceProvider).fetchFeedPage(
            tab: current.currentTab,
            limit: 12,
          );
      final mapper = const HomeMapper();
      state = AsyncData(
        current.copyWith(
          banner: bundle.banner,
          shortcuts: bundle.shortcuts,
          feed: page.items.map(mapper.feed).toList(),
          isRefreshing: false,
          isLoadingMore: false,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          clearError: true,
        ),
      );
      await _writeSnapshot(state.asData!.value);
    } catch (e) {
      state = AsyncData(current.copyWith(isRefreshing: false, error: e.toString()));
    }
  }

  Future<void> switchTab(String tab) async {
    final current = state.asData?.value ?? const HomeUiState();
    state = AsyncData(
      current.copyWith(
        currentTab: tab,
        isRefreshing: true,
        isLoadingMore: false,
        clearError: true,
      ),
    );
    try {
      final remote = ref.read(homeRemoteDataSourceProvider);
      final mapper = const HomeMapper();
      final page = await remote.fetchFeedPage(tab: tab, limit: 12);
      state = AsyncData(
        current.copyWith(
          currentTab: tab,
          feed: page.items.map(mapper.feed).toList(),
          isRefreshing: false,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
      await _writeSnapshot(state.asData!.value);
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          currentTab: tab,
          isRefreshing: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null) return;
    if (!current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await ref.read(homeRemoteDataSourceProvider).fetchFeedPage(
            tab: current.currentTab,
            cursor: current.nextCursor,
            limit: 12,
          );
      final mapper = const HomeMapper();
      final merged = [...current.feed, ...page.items.map(mapper.feed)];
      state = AsyncData(
        current.copyWith(
          feed: merged,
          isLoadingMore: false,
          hasMore: page.hasMore,
          nextCursor: page.nextCursor,
          clearError: true,
        ),
      );
      await _writeSnapshot(state.asData!.value);
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }

  Future<HomeUiState?> _readSnapshot() async {
    final raw = await ref.read(localStorageProvider).getString(CacheKeys.homeFeedSnapshot);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;
      final bannerRaw = decoded['banner'];
      final shortcutsRaw = decoded['shortcuts'];
      final feedRaw = decoded['feed'];
      final banner = bannerRaw is Map<String, dynamic>
          ? HomeBannerEntity(
              title: (bannerRaw['title'] ?? '').toString(),
              subtitle: (bannerRaw['subtitle'] ?? '').toString(),
              cta: (bannerRaw['cta'] ?? '').toString(),
            )
          : null;
      final shortcuts = shortcutsRaw is List
          ? shortcutsRaw
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => HomeShortcutEntity(
                  key: (e['key'] ?? '').toString(),
                  title: (e['title'] ?? '').toString(),
                  action: (e['action'] ?? '').toString().isEmpty ? null : (e['action'] ?? '').toString(),
                  target: (e['target'] ?? '').toString().isEmpty ? null : (e['target'] ?? '').toString(),
                ),
              )
              .toList()
          : const <HomeShortcutEntity>[];
      final feed = feedRaw is List
          ? feedRaw
              .whereType<Map<String, dynamic>>()
              .map(
                (e) => HomeFeedEntity(
                  id: (e['id'] ?? '').toString(),
                  title: (e['title'] ?? '').toString(),
                  summary: (e['summary'] ?? '').toString(),
                  author: (e['author'] ?? '').toString(),
                  likes: (e['likes'] as num?)?.toInt() ?? 0,
                  body: (e['body'] ?? '').toString().isEmpty ? null : (e['body'] ?? '').toString(),
                  media: ((e['media'] as List?) ?? const [])
                      .map((v) => v.toString())
                      .where((v) => v.isNotEmpty)
                      .toList(),
                  tags: ((e['tags'] as List?) ?? const [])
                      .map((v) => v.toString())
                      .where((v) => v.isNotEmpty)
                      .toList(),
                ),
              )
              .toList()
          : const <HomeFeedEntity>[];
      return HomeUiState(
        banner: banner,
        shortcuts: shortcuts,
        feed: feed,
        currentTab: (decoded['currentTab'] ?? 'recommend').toString(),
        hasMore: (decoded['hasMore'] as bool?) ?? false,
        nextCursor: (decoded['nextCursor'] ?? '').toString().isEmpty ? null : (decoded['nextCursor'] ?? '').toString(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeSnapshot(HomeUiState data) async {
    final payload = <String, dynamic>{
      'banner': data.banner == null
          ? null
          : {
              'title': data.banner!.title,
              'subtitle': data.banner!.subtitle,
              'cta': data.banner!.cta,
            },
      'shortcuts': data.shortcuts
          .map(
            (e) => {
              'key': e.key,
              'title': e.title,
              'action': e.action,
              'target': e.target,
            },
          )
          .toList(),
      'feed': data.feed
          .map(
            (e) => {
              'id': e.id,
              'title': e.title,
              'summary': e.summary,
              'author': e.author,
              'likes': e.likes,
              'body': e.body,
              'media': e.media,
              'tags': e.tags,
            },
          )
          .toList(),
      'currentTab': data.currentTab,
      'hasMore': data.hasMore,
      'nextCursor': data.nextCursor,
    };
    await ref.read(localStorageProvider).setString(CacheKeys.homeFeedSnapshot, jsonEncode(payload));
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeUiState>(HomeNotifier.new);
