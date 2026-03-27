import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/state/discover_ui_state.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';

class DiscoverFeedController extends ChangeNotifier {
  DiscoverFeedController({
    required HomeRemoteDataSource remote,
    required HomeMapper mapper,
  })  : _remote = remote,
        _mapper = mapper;

  final HomeRemoteDataSource _remote;
  final HomeMapper _mapper;

  static const tabs = ['hot', 'local', 'event', 'topic', 'live'];
  int tabIndex = 0;
  final Map<int, _DiscoverTabCache> _tabCache = {};

  DiscoverUiState state = const DiscoverUiState(isLoading: true);

  String get tabKey => tabs[tabIndex];

  Future<void> initialize() async {
    await loadInitial();
  }

  void hydrateFromSnapshot({
    required int index,
    required DiscoverUiState snapshot,
  }) {
    tabIndex = index.clamp(0, tabs.length - 1);
    state = snapshot;
    _tabCache[tabIndex] = _DiscoverTabCache(
      items: state.items,
      hasMore: state.hasMore,
      nextCursor: state.nextCursor,
    );
    notifyListeners();
  }

  Future<void> switchTab(int index) async {
    if (index == tabIndex) return;
    tabIndex = index;
    final cached = _tabCache[index];
    if (cached != null) {
      state = state.copyWith(
        items: cached.items,
        isLoading: false,
        isLoadingMore: false,
        hasMore: cached.hasMore,
        nextCursor: cached.nextCursor,
        clearError: true,
      );
      notifyListeners();
      return;
    }
    await loadInitial();
  }

  Future<void> loadInitial() async {
    final hadItems = state.items.isNotEmpty;
    state = state.copyWith(
      isLoading: !hadItems,
      isLoadingMore: false,
      hasMore: hadItems ? state.hasMore : false,
      nextCursor: hadItems ? state.nextCursor : null,
      error: null,
      clearError: true,
    );
    notifyListeners();
    try {
      final page = await _remote.fetchDiscoverFeedPage(tab: tabKey, limit: 12);
      state = state.copyWith(
        items: page.items.map(_mapper.feed).toList(),
        isLoading: false,
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        clearError: true,
      );
      _tabCache[tabIndex] = _DiscoverTabCache(
        items: state.items,
        hasMore: state.hasMore,
        nextCursor: state.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    notifyListeners();
    try {
      final page = await _remote.fetchDiscoverFeedPage(
        tab: tabKey,
        cursor: state.nextCursor,
        limit: 12,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items.map(_mapper.feed)],
        isLoadingMore: false,
        hasMore: page.hasMore,
        nextCursor: page.nextCursor,
        clearError: true,
      );
      _tabCache[tabIndex] = _DiscoverTabCache(
        items: state.items,
        hasMore: state.hasMore,
        nextCursor: state.nextCursor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }
}

class _DiscoverTabCache {
  const _DiscoverTabCache({
    required this.items,
    required this.hasMore,
    required this.nextCursor,
  });

  final List<HomeFeedEntity> items;
  final bool hasMore;
  final String? nextCursor;
}
