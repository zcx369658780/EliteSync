import 'package:flutter_elitesync_module/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';

class HomeUiState {
  const HomeUiState({
    this.banner,
    this.shortcuts = const [],
    this.feed = const [],
    this.currentTab = 'recommend',
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.nextCursor,
    this.error,
  });

  final HomeBannerEntity? banner;
  final List<HomeShortcutEntity> shortcuts;
  final List<HomeFeedEntity> feed;
  final String currentTab;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  static const _unset = Object();

  HomeUiState copyWith({
    HomeBannerEntity? banner,
    List<HomeShortcutEntity>? shortcuts,
    List<HomeFeedEntity>? feed,
    String? currentTab,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    Object? nextCursor = _unset,
    String? error,
    bool clearError = false,
  }) {
    return HomeUiState(
      banner: banner ?? this.banner,
      shortcuts: shortcuts ?? this.shortcuts,
      feed: feed ?? this.feed,
      currentTab: currentTab ?? this.currentTab,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: identical(nextCursor, _unset) ? this.nextCursor : nextCursor as String?,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
