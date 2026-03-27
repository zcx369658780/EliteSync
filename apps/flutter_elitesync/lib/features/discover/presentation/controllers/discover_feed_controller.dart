import 'package:flutter/material.dart';
import 'package:flutter_elitesync/features/discover/presentation/state/discover_ui_state.dart';
import 'package:flutter_elitesync/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync/features/home/data/mapper/home_mapper.dart';

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

  DiscoverUiState state = const DiscoverUiState(isLoading: true);

  String get tabKey => tabs[tabIndex];

  Future<void> initialize() async {
    await loadInitial();
  }

  Future<void> switchTab(int index) async {
    if (index == tabIndex) return;
    tabIndex = index;
    await loadInitial();
  }

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      isLoadingMore: false,
      hasMore: false,
      nextCursor: null,
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
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }
}
