import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync/features/home/data/repository/home_repository_impl.dart';
import 'package:flutter_elitesync/features/home/domain/repository/home_repository.dart';
import 'package:flutter_elitesync/features/home/domain/usecases/fetch_home_feed_usecase.dart';
import 'package:flutter_elitesync/features/home/presentation/state/home_ui_state.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

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
    final bundle = await ref.read(fetchHomeFeedUseCaseProvider).call();
    const initialTab = 'recommend';
    final page = await ref.read(homeRemoteDataSourceProvider).fetchFeedPage(
          tab: initialTab,
          limit: 12,
        );
    final mapper = const HomeMapper();
    return HomeUiState(
      banner: bundle.banner,
      shortcuts: bundle.shortcuts,
      feed: page.items.map(mapper.feed).toList(),
      currentTab: initialTab,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
    );
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
    } catch (e) {
      state = AsyncData(
        current.copyWith(
          isLoadingMore: false,
          error: e.toString(),
        ),
      );
    }
  }
}

final homeProvider = AsyncNotifierProvider<HomeNotifier, HomeUiState>(HomeNotifier.new);
