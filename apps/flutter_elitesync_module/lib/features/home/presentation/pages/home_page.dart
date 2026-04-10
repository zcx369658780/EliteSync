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
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/home/presentation/widgets/media_feed_card.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

enum _HomeCtaState { questionnaire, profile, match, discover }

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
    await ref
        .read(localStorageProvider)
        .setInt(CacheKeys.homeSelectedTab, _selectedTabIndex);
  }

  Future<void> _loadSearchHistory() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.homeSearchHistory);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        setState(() {
          _recentSearches = decoded
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .take(8)
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _addSearchHistory(String term) async {
    final t = term.trim();
    if (t.isEmpty) return;
    final next = [
      t,
      ..._recentSearches.where((e) => e.toLowerCase() != t.toLowerCase()),
    ].take(8).toList();
    setState(() => _recentSearches = next);
    await ref
        .read(localStorageProvider)
        .setString(CacheKeys.homeSearchHistory, jsonEncode(next));
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
    final statusAsync = ref.watch(statusPostsProvider);

    return asyncState.when(
      loading: () => const AppLoadingSkeleton(lines: 8),
      error: (e, _) => AppErrorState(
        title: '首页加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () => ref.read(homeProvider.notifier).refresh(),
      ),
      data: (state) {
        final liteMode =
            ref.watch(performanceLiteModeProvider).asData?.value ?? false;
        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, _) {
            final t = context.appTokens;
            final showRecentChips = _searchFocused && searchQuery.isEmpty;
            final filteredFeed = _filterFeed(state.feed);
            final ctaState = _resolveCtaState(state.shortcuts);
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
                    onRightActionTap: () =>
                        context.push(AppRouteNames.discover),
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: t.textSecondary),
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
                                  separatorBuilder: (_, index) =>
                                      SizedBox(width: t.spacing.xs),
                                  itemBuilder: (context, index) {
                                    final term = _recentSearches[index];
                                    return AppChoiceChip(
                                      label: term,
                                      onTap: () {
                                        _searchController.text = term;
                                        _searchController.selection =
                                            TextSelection.collapsed(
                                              offset: term.length,
                                            );
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
                      const tabKeys = [
                        'recommend',
                        'nearby',
                        'topic',
                        'event',
                        'inspire',
                      ];
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
                  padding: EdgeInsets.fromLTRB(
                    0,
                    t.spacing.xs,
                    0,
                    t.spacing.huge,
                  ),
                  children: [
                    _ShortcutRow(
                      shortcuts: state.shortcuts,
                      onShortcutTap: (item) =>
                          _handleShortcutTap(context, item),
                    ),
                    SizedBox(height: t.spacing.sm),
                    _StatusPreviewSection(
                      statusAsync: statusAsync,
                      onTapMore: () => context.push(AppRouteNames.statusSquare),
                      onRefresh: () => ref.invalidate(statusPostsProvider),
                    ),
                    SizedBox(height: t.spacing.sm),
                    _HomeHeroCard(
                      title: _heroTitle(ctaState),
                      subtitle: _heroSubtitle(ctaState),
                      primaryLabel: _primaryCtaLabel(ctaState),
                      secondaryLabel: _secondaryCtaLabel(ctaState),
                      onTapPrimary: () => _openPrimaryPath(context, ctaState),
                      onTapSecondary: () =>
                          _openSecondaryPath(context, ctaState),
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
                      AppEmptyState(
                        title: _emptyTitle(ctaState),
                        description: _emptyDescription(ctaState),
                        actionLabel: _primaryCtaLabel(ctaState),
                        onAction: () => _openPrimaryPath(context, ctaState),
                      )
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
                      const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
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
      _searchIndex[item.id] =
          '${item.title} ${item.summary} ${item.author} ${item.tags.join(' ')}'
              .toLowerCase();
    }
    final filtered = items
        .where((e) => (_searchIndex[e.id] ?? '').contains(q))
        .toList();
    _cachedFilteredItems = filtered;
    return filtered;
  }

  void _handleShortcutTap(BuildContext context, HomeShortcutEntity item) {
    final action = (item.action ?? '').trim().toLowerCase();
    final target = (item.target ?? '').trim();
    if (action == 'route' && target.isNotEmpty) {
      if (!_isSafeRouteTarget(target)) {
        AppFeedback.showInfo(context, '入口暂不可用，已为你打开发现页');
        context.go(AppRouteNames.discover);
        return;
      }
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
      case 'status':
        context.push(AppRouteNames.statusSquare);
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

  bool _isSafeRouteTarget(String target) {
    if (!target.startsWith('/')) return false;
    const allowedPrefixes = <String>{
      AppRouteNames.home,
      AppRouteNames.discover,
      AppRouteNames.match,
      AppRouteNames.messages,
      AppRouteNames.profile,
      AppRouteNames.statusSquare,
      AppRouteNames.questionnaire,
      AppRouteNames.editProfile,
      AppRouteNames.astroProfile,
      AppRouteNames.settings,
      AppRouteNames.aboutUpdate,
      AppRouteNames.contentDetail,
    };
    for (final prefix in allowedPrefixes) {
      if (target == prefix || target.startsWith('$prefix/')) {
        return true;
      }
    }
    return false;
  }

  Future<void> _rememberPreferredTag(HomeFeedEntity item) async {
    if (item.tags.isEmpty) return;
    final local = ref.read(localStorageProvider);
    final map =
        await local.getJson(CacheKeys.contentPreferredTagsMap) ??
        <String, dynamic>{};
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
    final ranked = next.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = ranked.take(8).toList();
    await local.setJson(CacheKeys.contentPreferredTagsMap, {
      for (final e in top) e.key: e.value,
    });
    if (top.isNotEmpty) {
      await local.setString(CacheKeys.contentPreferredTag, top.first.key);
    }
  }

  _HomeCtaState _resolveCtaState(List<HomeShortcutEntity> shortcuts) {
    if (_hasShortcut(shortcuts, {'questionnaire'})) {
      return _HomeCtaState.questionnaire;
    }
    if (_hasShortcut(shortcuts, {'profile'})) {
      return _HomeCtaState.profile;
    }
    if (_hasShortcut(shortcuts, {'match', 'matching'})) {
      return _HomeCtaState.match;
    }
    return _HomeCtaState.discover;
  }

  void _openPrimaryPath(BuildContext context, _HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        context.push(AppRouteNames.questionnaire);
        return;
      case _HomeCtaState.profile:
        context.push(AppRouteNames.editProfile);
        return;
      case _HomeCtaState.match:
        context.go(AppRouteNames.match);
        return;
      case _HomeCtaState.discover:
        context.go(AppRouteNames.discover);
        return;
    }
  }

  String _primaryCtaLabel(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '继续完善问卷';
      case _HomeCtaState.profile:
        return '先完善资料';
      case _HomeCtaState.match:
        return '查看本周匹配';
      case _HomeCtaState.discover:
        return '查看推荐内容';
    }
  }

  String _secondaryCtaLabel(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '先完善资料';
      case _HomeCtaState.profile:
        return '继续问卷';
      case _HomeCtaState.match:
        return '继续完善问卷';
      case _HomeCtaState.discover:
        return '完善资料';
    }
  }

  void _openSecondaryPath(BuildContext context, _HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        context.push(AppRouteNames.editProfile);
        return;
      case _HomeCtaState.profile:
        context.push(AppRouteNames.questionnaire);
        return;
      case _HomeCtaState.match:
        context.push(AppRouteNames.questionnaire);
        return;
      case _HomeCtaState.discover:
        context.push(AppRouteNames.editProfile);
        return;
    }
  }

  String _heroTitle(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '先完成问卷，更快看到合适的人';
      case _HomeCtaState.profile:
        return '补全资料，匹配会更精准';
      case _HomeCtaState.match:
        return '你有新的匹配结果可查看';
      case _HomeCtaState.discover:
        return '今天有新的推荐内容';
    }
  }

  String _heroSubtitle(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '先补齐关键问卷，再看匹配解释和行动建议';
      case _HomeCtaState.profile:
        return '补全生日、出生地等信息，可提升推荐可信度';
      case _HomeCtaState.match:
        return '建议先查看匹配亮点，再决定是否进入进一步交流';
      case _HomeCtaState.discover:
        return '可以先浏览精选，再返回完善问卷和资料';
    }
  }

  String _emptyTitle(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '先完成问卷，系统再为你推荐';
      case _HomeCtaState.profile:
        return '先补全资料，推荐会更贴近你';
      case _HomeCtaState.match:
      case _HomeCtaState.discover:
        return '当前暂无推荐内容';
    }
  }

  String _emptyDescription(_HomeCtaState state) {
    switch (state) {
      case _HomeCtaState.questionnaire:
        return '完成问卷后，将自动生成更准确的推荐与匹配解释';
      case _HomeCtaState.profile:
        return '完善资料后，首页内容会按你的状态优先更新';
      case _HomeCtaState.match:
      case _HomeCtaState.discover:
        return '可能是弱网或冷启动，请下拉刷新，或先去完成问卷与资料';
    }
  }

  bool _hasShortcut(List<HomeShortcutEntity> shortcuts, Set<String> keys) {
    for (final item in shortcuts) {
      final key = item.key.trim().toLowerCase();
      if (keys.contains(key)) return true;
    }
    return false;
  }

  @override
  bool get wantKeepAlive => true;
}

class _ShortcutRow extends StatelessWidget {
  const _ShortcutRow({required this.shortcuts, this.onShortcutTap});

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
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: t.brandPrimary,
                    ),
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

class _StatusPreviewSection extends StatelessWidget {
  const _StatusPreviewSection({
    required this.statusAsync,
    required this.onTapMore,
    required this.onRefresh,
  });

  final AsyncValue<List<StatusPostEntity>> statusAsync;
  final VoidCallback onTapMore;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return statusAsync.when(
      loading: () => const AppLoadingSkeleton(lines: 2),
      error: (e, _) => AppInfoSectionCard(
        title: '状态广场',
        subtitle: '服务端状态流',
        leadingIcon: Icons.dynamic_feed_rounded,
        child: AppErrorState(
          title: '状态广场加载失败',
          description: e.toString(),
          retryLabel: '重新加载',
          onRetry: onRefresh,
        ),
      ),
      data: (items) {
        final posts = items.take(3).toList();
        if (posts.isEmpty) {
          return AppInfoSectionCard(
            title: '状态广场',
            subtitle: '服务端状态流',
            leadingIcon: Icons.dynamic_feed_rounded,
            child: AppEmptyState(
              title: '还没有公开状态',
              description: '先去发布一条状态，再回来看广场流。',
              actionLabel: '发布状态',
              onAction: onTapMore,
            ),
          );
        }

        return AppInfoSectionCard(
          title: '状态广场',
          subtitle: '服务端最新状态',
          leadingIcon: Icons.dynamic_feed_rounded,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTapMore,
                  child: const Text('查看更多'),
                ),
              ),
              for (var i = 0; i < posts.length; i++) ...[
                _HomeStatusPreviewCard(post: posts[i], onTap: onTapMore),
                if (i < posts.length - 1) SizedBox(height: t.spacing.xs),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HomeStatusPreviewCard extends StatelessWidget {
  const _HomeStatusPreviewCard({required this.post, required this.onTap});

  final StatusPostEntity post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final time = MaterialLocalizations.of(
      context,
    ).formatShortDate(post.createdAt);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(t.spacing.sm),
          decoration: BoxDecoration(
            color: t.surface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.overlay.withValues(alpha: 0.22)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    post.visibilityLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.xs / 2),
              Text(
                '${post.authorName} · ${post.locationName.isEmpty ? '同城' : post.locationName} · $time',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
              SizedBox(height: t.spacing.xxs),
              Text(
                '${post.authorLayerLabel} · ${post.visibilityTierLabel}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                post.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeHeroCard extends StatelessWidget {
  const _HomeHeroCard({
    required this.title,
    required this.subtitle,
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onTapPrimary,
    required this.onTapSecondary,
  });

  final String title;
  final String subtitle;
  final String primaryLabel;
  final String secondaryLabel;
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
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
          SizedBox(height: t.spacing.sm),
          Row(
            children: [
              AppChoiceChip(
                label: primaryLabel,
                leading: const Icon(Icons.flag_rounded),
                selected: true,
                onTap: onTapPrimary,
              ),
              SizedBox(width: t.spacing.xs),
              AppChoiceChip(
                label: secondaryLabel,
                leading: const Icon(Icons.navigate_next_rounded),
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
