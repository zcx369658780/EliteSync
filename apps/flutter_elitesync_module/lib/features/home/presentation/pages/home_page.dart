import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/browse_top_search_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/category_tab_strip.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/widgets/media_feed_card.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with AutomaticKeepAliveClientMixin<HomePage> {
  int _selectedTabIndex = 0;
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  static const _tabs = ['推荐', '附近', '话题', '活动', '灵感'];
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  Timer? _searchUiDebounce;
  List<String> _recentSearches = const [];
  bool _searchFocused = false;
  List<HomeFeedEntity> _cachedSourceItems = const [];
  String _cachedFilterQuery = '';
  List<HomeFeedEntity> _cachedFilteredItems = const [];
  final Map<String, String> _searchIndex = <String, String>{};

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode()
      ..addListener(() {
        if (!mounted) return;
        setState(() => _searchFocused = _searchFocusNode.hasFocus);
      });
    _scrollController.addListener(_onScroll);
    _loadUiPrefs();
    _loadSearchHistory();
  }

  Future<void> _loadUiPrefs() async {
    final local = ref.read(localStorageProvider);
    final savedTab = await local.getInt(CacheKeys.homeSelectedTab);
    if (!mounted || savedTab == null) return;
    final safe = savedTab.clamp(0, _tabs.length - 1);
    setState(() => _selectedTabIndex = safe);
    const tabKeys = ['recommend', 'nearby', 'topic', 'event', 'inspire'];
    await ref.read(homeProvider.notifier).switchTab(tabKeys[safe]);
  }

  Future<void> _saveUiPrefs() async {
    await ref.read(localStorageProvider).setInt(CacheKeys.homeSelectedTab, _selectedTabIndex);
  }

  Future<void> _loadSearchHistory() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.homeSearchHistory);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        setState(() {
          _recentSearches = decoded.map((e) => e.toString()).where((e) => e.isNotEmpty).take(8).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _addSearchHistory(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final next = [t, ..._recentSearches.where((e) => e.toLowerCase() != t.toLowerCase())].take(8).toList();
    setState(() => _recentSearches = next);
    await ref.read(localStorageProvider).setString(CacheKeys.homeSearchHistory, jsonEncode(next));
  }

  void _onSearchChanged(String value) {
    final v = value.trim();
    _searchUiDebounce?.cancel();
    _searchUiDebounce = Timer(const Duration(milliseconds: 90), () {
      if (!mounted || _searchQueryNotifier.value == v) return;
      _searchQueryNotifier.value = v;
    });
  }

  Future<void> _clearSearch() async {
    _searchUiDebounce?.cancel();
    _searchController.clear();
    _searchQueryNotifier.value = '';
  }

  Future<void> _onSearchSubmitted(String value) async {
    final v = value.trim();
    if (v.isEmpty) return;
    await _addSearchHistory(v);
    _searchFocusNode.unfocus();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 220) {
      ref.read(homeProvider.notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _searchUiDebounce?.cancel();
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final asyncState = ref.watch(homeProvider);

    return asyncState.when(
      loading: () => const AppLoadingSkeleton(lines: 8),
      error: (e, _) => AppErrorState(
        title: '首页加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () => ref.read(homeProvider.notifier).refresh(),
      ),
      data: (state) {
        final liteMode = ref.watch(performanceLiteModeProvider).asData?.value ?? false;
        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, _) {
            final t = context.appTokens;
            final showRecentChips = _searchFocused && searchQuery.isEmpty;
            final filteredFeed = _filterFeed(state.feed);
            return BrowseScaffold(
              header: Column(
                children: [
                  BrowseTopSearchBar(
                    hint: '搜索话题、活动、用户',
                    editable: true,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    onSubmitted: (v) => _onSearchSubmitted(v),
                    onClear: _clearSearch,
                    onRightActionTap: () => context.push(AppRouteNames.discover),
                  ),
                  AnimatedSize(
                    duration: liteMode ? t.motionFast : t.motionNormal,
                    curve: Curves.easeOutCubic,
                    child: searchQuery.isNotEmpty
                        ? Column(
                            children: [
                              SizedBox(height: t.spacing.xs),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '已筛选关键词: $searchQuery（找到 ${filteredFeed.length} 条）',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                                    ),
                                  ),
                                  AppChoiceChip(
                                    label: '清除',
                                    leading: const Icon(Icons.close_rounded),
                                    onTap: _clearSearch,
                                  ),
                                ],
                              ),
                            ],
                          )
                        : (showRecentChips && _recentSearches.isNotEmpty)
                            ? Column(
                                children: [
                                  SizedBox(height: t.spacing.xs),
                                  SizedBox(
                                    height: 32,
                                    child: ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _recentSearches.length,
                                      separatorBuilder: (_, index) => SizedBox(width: t.spacing.xs),
                                      itemBuilder: (context, index) {
                                        final term = _recentSearches[index];
                                        return AppChoiceChip(
                                          label: term,
                                          onTap: () {
                                            _searchController.text = term;
                                            _searchController.selection = TextSelection.collapsed(offset: term.length);
                                            _onSearchChanged(term);
                                            _searchFocusNode.unfocus();
                                          },
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                  ),
                  SizedBox(height: t.spacing.sm),
                  CategoryTabStrip(
                    tabs: _tabs,
                    selectedIndex: _selectedTabIndex,
                    onSelected: (index) {
                      _searchFocusNode.unfocus();
                      setState(() => _selectedTabIndex = index);
                      _saveUiPrefs();
                      const tabKeys = ['recommend', 'nearby', 'topic', 'event', 'inspire'];
                      ref.read(homeProvider.notifier).switchTab(tabKeys[index]);
                      if (_scrollController.hasClients) {
                        _scrollController.animateTo(
                          0,
                          duration: liteMode ? t.motionFast : t.motionNormal,
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () => ref.read(homeProvider.notifier).refresh(),
                child: ListView(
                  controller: _scrollController,
                  cacheExtent: liteMode ? 480 : 1200,
                  padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
                children: [
                  _ShortcutRow(
                    shortcuts: state.shortcuts,
                    onShortcutTap: (item) => _handleShortcutTap(context, item),
                  ),
                  SizedBox(height: t.spacing.sm),
                  _HomeHeroCard(
                    onTapPrimary: () => context.go(AppRouteNames.match),
                    onTapSecondary: () => context.push(AppRouteNames.questionnaire),
                  ),
                  SizedBox(height: t.spacing.md),
                  Text(
                    '${_tabs[_selectedTabIndex]}精选',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.sm),
                    if (filteredFeed.isEmpty)
                      const AppEmptyState(title: '暂无推荐', description: '完成问卷后将为你推荐更多内容')
                    else
                      _MasonryFeed(
                        feed: filteredFeed,
                        highlightQuery: searchQuery,
                        onCardTap: (item) {
                          _rememberPreferredTag(item);
                          context.push(
                            '${AppRouteNames.contentDetail}/${item.id}',
                            extra: item,
                          );
                        },
                      ),
                    if (state.isLoadingMore) ...[
                      SizedBox(height: t.spacing.sm),
                      const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  List<HomeFeedEntity> _filterFeed(List<HomeFeedEntity> items) {
    final q = _searchQueryNotifier.value.trim().toLowerCase();
    if (identical(items, _cachedSourceItems) && q == _cachedFilterQuery) {
      return _cachedFilteredItems;
    }
    _cachedSourceItems = items;
    _cachedFilterQuery = q;
    if (q.isEmpty) {
      _cachedFilteredItems = items;
      return items;
    }

    final ids = items.map((e) => e.id).toSet();
    _searchIndex.removeWhere((key, _) => !ids.contains(key));
    for (final item in items) {
      _searchIndex.putIfAbsent(
        item.id,
        () => '${item.title} ${item.summary} ${item.author} ${item.tags.join(' ')}'.toLowerCase(),
      );
    }
    final filtered = items.where((e) => (_searchIndex[e.id] ?? '').contains(q)).toList();
    _cachedFilteredItems = filtered;
    return filtered;
  }

  void _handleShortcutTap(BuildContext context, HomeShortcutEntity item) {
    final action = (item.action ?? '').trim().toLowerCase();
    final target = (item.target ?? '').trim();
    if (action == 'route' && target.isNotEmpty) {
      const tabRootRoutes = <String>{
        AppRouteNames.home,
        AppRouteNames.discover,
        AppRouteNames.match,
        AppRouteNames.messages,
        AppRouteNames.profile,
      };
      if (tabRootRoutes.contains(target)) {
        context.go(target);
      } else {
        context.push(target);
      }
      return;
    }

    final key = item.key.trim().toLowerCase();
    switch (key) {
      case 'questionnaire':
        context.push(AppRouteNames.questionnaire);
        break;
      case 'mbti':
        AppFeedback.showInfo(context, '性格测试已关闭，入口暂不可用');
        break;
      case 'astro':
        context.push(AppRouteNames.astroProfile);
        break;
      case 'profile':
        context.push(AppRouteNames.editProfile);
        break;
      case 'settings':
        context.push(AppRouteNames.settings);
        break;
      case 'discover':
        context.go(AppRouteNames.discover);
        break;
      case 'messages':
      case 'message':
      case 'chat':
        context.go(AppRouteNames.messages);
        break;
      case 'match':
      case 'matching':
        context.go(AppRouteNames.match);
        break;
      case 'about':
      case 'update':
        context.push(AppRouteNames.aboutUpdate);
        break;
      default:
        context.go(AppRouteNames.discover);
        AppFeedback.showInfo(context, '已为你打开「发现」：${item.title}');
    }
  }

  Future<void> _rememberPreferredTag(HomeFeedEntity item) async {
    if (item.tags.isEmpty) return;
    final local = ref.read(localStorageProvider);
    final map = await local.getJson(CacheKeys.contentPreferredTagsMap) ?? <String, dynamic>{};
    final next = <String, int>{};
    for (final e in map.entries) {
      final k = e.key.trim();
      final v = (e.value as num?)?.toInt() ?? 0;
      if (k.isEmpty || v <= 0) continue;
      // Mild decay to avoid one-time clicks dominating forever.
      final decayed = (v * 0.97).floor();
      if (decayed > 0) next[k] = decayed;
    }
    for (final t in item.tags.take(2)) {
      final tag = t.trim();
      if (tag.isEmpty) continue;
      next[tag] = (next[tag] ?? 0) + 5;
    }
    final ranked = next.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(8).toList();
    await local.setJson(CacheKeys.contentPreferredTagsMap, {for (final e in top) e.key: e.value});
    if (top.isNotEmpty) {
      await local.setString(CacheKeys.contentPreferredTag, top.first.key);
    }
  }

  @override
  bool get wantKeepAlive => true;
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({
    required this.shortcuts,
    this.onShortcutTap,
  });

  final List<HomeShortcutEntity> shortcuts;
  final ValueChanged<HomeShortcutEntity>? onShortcutTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    if (shortcuts.isEmpty) return const SizedBox.shrink();
    int rank(HomeShortcutEntity item) {
      final k = item.key.trim().toLowerCase();
      switch (k) {
        case 'questionnaire':
          return 0;
        case 'match':
        case 'matching':
          return 1;
        case 'mbti':
          return 2;
        case 'astro':
          return 3;
        default:
          return 9;
      }
    }

    final ordered = [...shortcuts]..sort((a, b) => rank(a).compareTo(rank(b)));
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ordered.length,
        separatorBuilder: (context, index) => SizedBox(width: t.spacing.xs),
        itemBuilder: (context, index) {
          final item = ordered[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(t.radius.pill),
              onTap: onShortcutTap == null ? null : () => onShortcutTap!(item),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.sm,
                  vertical: t.spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: t.browseChip,
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  border: Border.all(color: t.browseBorder),
                ),
                child: Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 14, color: t.brandPrimary),
                    SizedBox(width: t.spacing.xxs),
                    Text(
                      item.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: t.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MasonryFeed extends StatelessWidget {
  const _MasonryFeed({
    required this.feed,
    required this.highlightQuery,
    required this.onCardTap,
  });

  final List<HomeFeedEntity> feed;
  final String highlightQuery;
  final ValueChanged<HomeFeedEntity> onCardTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final leftItems = <HomeFeedEntity>[];
    final rightItems = <HomeFeedEntity>[];
    for (var i = 0; i < feed.length; i++) {
      if (i.isEven) {
        leftItems.add(feed[i]);
      } else {
        rightItems.add(feed[i]);
      }
    }

    Widget buildColumn(List<HomeFeedEntity> items, int startIndex) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: t.spacing.sm),
              child: RepaintBoundary(
                child: MediaFeedCard(
                  item: items[i],
                  index: startIndex + i * 2,
                  highlightQuery: highlightQuery,
                  onTap: () => onCardTap(items[i]),
                ),
              ),
            ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: buildColumn(leftItems, 0)),
        SizedBox(width: t.spacing.sm),
        Expanded(child: buildColumn(rightItems, 1)),
      ],
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.onTapPrimary,
    required this.onTapSecondary,
  });

  final VoidCallback onTapPrimary;
  final VoidCallback onTapSecondary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandPrimary.withValues(alpha: 0.2),
            t.brandSecondary.withValues(alpha: 0.14),
          ],
        ),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '本周关系进展',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '你有新的匹配结果可查看',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            '建议先查看匹配亮点，再决定是否进入进一步交流',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                ),
          ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              AppChoiceChip(
                label: '查看本周匹配',
                leading: const Icon(Icons.favorite_rounded),
                selected: true,
                onTap: onTapPrimary,
              ),
              SizedBox(width: t.spacing.xs),
              AppChoiceChip(
                label: '继续完善问卷',
                leading: const Icon(Icons.quiz_rounded),
                onTap: onTapSecondary,
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: const [
              _HeroHintChip(label: '性格结果可刷新'),
              _HeroHintChip(label: '星盘画像可查看'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroHintChip extends StatelessWidget {
  const _HeroHintChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xs,
        vertical: t.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: t.browseSurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(t.radius.pill),
        border: Border.all(color: t.browseBorder),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
