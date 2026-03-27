import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';

class DiscoverUiState {
  static const _unset = Object();

  const DiscoverUiState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.nextCursor,
    this.error,
  });

  final List<HomeFeedEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final String? nextCursor;
  final String? error;

  DiscoverUiState copyWith({
    List<HomeFeedEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? nextCursor = _unset,
    Object? error = _unset,
    bool clearError = false,
  }) {
    return DiscoverUiState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      nextCursor: identical(nextCursor, _unset) ? this.nextCursor : nextCursor as String?,
      error: clearError
          ? null
          : (identical(error, _unset) ? this.error : error as String?),
    );
  }
}
