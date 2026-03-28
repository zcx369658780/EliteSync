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
import 'package:flutter_elitesync_module/design_system/components/tags/highlight_text.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/controllers/discover_feed_controller.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/state/discover_ui_state.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage>
    with AutomaticKeepAliveClientMixin<DiscoverPage> {
  static const Duration _snapshotTtl = Duration(hours: 6);
  int _tab = 0;
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  static const _tabs = ['热门', '同城', '活动', '话题', '直播'];
  final ScrollController _scrollController = ScrollController();
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final DiscoverFeedController _controller;
  Timer? _searchUiDebounce;
  Timer? _snapshotSaveDebounce;
  List<String> _recentSearches = const [];
  bool _searchFocused = false;
  bool _quickRefreshing = false;
  bool _initialized = false;
  final Map<int, double> _tabScrollOffsets = <int, double>{};
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
    final remote = ref.read(homeRemoteDataSourceProvider);
    _controller = DiscoverFeedController(
      remote: remote,
      mapper: const HomeMapper(),
    )..addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (_initialized || !mounted) return;
    _initialized = true;
    await _loadUiPrefs();
    await _loadSearchHistory();
    await _loadFeedSnapshot();
    if (!mounted) return;
    await _controller.initialize();
  }

  Future<void> _loadUiPrefs() async {
    final local = ref.read(localStorageProvider);
    final savedTab = await local.getInt(CacheKeys.discoverSelectedTab);
    if (!mounted || savedTab == null) return;
    final safe = savedTab.clamp(0, _tabs.length - 1);
    setState(() => _tab = safe);
    _controller.tabIndex = safe;
  }

  Future<void> _saveUiPrefs() async {
    await ref.read(localStorageProvider).setInt(CacheKeys.discoverSelectedTab, _tab);
  }

  Future<void> _loadSearchHistory() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.discoverSearchHistory);
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
    await ref.read(localStorageProvider).setString(CacheKeys.discoverSearchHistory, jsonEncode(next));
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

  @override
  void dispose() {
    _searchUiDebounce?.cancel();
    _snapshotSaveDebounce?.cancel();
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _snapshotSaveDebounce?.cancel();
    _snapshotSaveDebounce = Timer(const Duration(milliseconds: 220), () {
      _saveFeedSnapshot();
    });
    if (mounted) setState(() {});
  }

  Future<void> _loadFeedSnapshot() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.discoverFeedSnapshot);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      final savedAtMs = (decoded['savedAtMs'] as num?)?.toInt() ?? 0;
      if (savedAtMs <= 0) return;
      final ageMs = DateTime.now().millisecondsSinceEpoch - savedAtMs;
      if (ageMs > _snapshotTtl.inMilliseconds) return;
      final index = (decoded['tabIndex'] as num?)?.toInt() ?? 0;
      final list = (decoded['items'] as List<dynamic>? ?? const []);
      final items = list
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
          .toList();
      if (items.isEmpty) return;
      final snapshot = DiscoverUiState(
        items: items,
        isLoading: false,
        isLoadingMore: false,
        hasMore: (decoded['hasMore'] as bool?) ?? false,
        nextCursor: (decoded['nextCursor'] ?? '').toString().isEmpty ? null : (decoded['nextCursor'] ?? '').toString(),
      );
      // Only hydrate from snapshot before first remote init to avoid stale overwrite.
      if (_controller.state.isLoading) {
        _controller.hydrateFromSnapshot(index: index, snapshot: snapshot);
      }
      setState(() => _tab = index.clamp(0, _tabs.length - 1));
    } catch (_) {}
  }

  Future<void> _saveFeedSnapshot() async {
    final s = _controller.state;
    if (s.items.isEmpty) return;
    final payload = <String, dynamic>{
      'tabIndex': _tab,
      'hasMore': s.hasMore,
      'nextCursor': s.nextCursor,
      'savedAtMs': DateTime.now().millisecondsSinceEpoch,
      'items': s.items
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
    };
    await ref.read(localStorageProvider).setString(CacheKeys.discoverFeedSnapshot, jsonEncode(payload));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    _tabScrollOffsets[_tab] = pos.pixels;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      _controller.loadMore();
    }
  }

  Future<void> _quickRefresh() async {
    if (_quickRefreshing) return;
    setState(() => _quickRefreshing = true);
    try {
      await _controller.loadInitial();
      if (!mounted) return;
      AppFeedback.showInfo(context, '已刷新发现内容');
    } finally {
      if (mounted) {
        setState(() => _quickRefreshing = false);
      }
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
  Widget build(BuildContext context) {
    super.build(context);
    final liteMode = ref.watch(performanceLiteModeProvider).asData?.value ?? false;
    final state = _controller.state;
    return ValueListenableBuilder<String>(
      valueListenable: _searchQueryNotifier,
      builder: (context, searchQuery, _) {
        final t = context.appTokens;
        final showRecentChips = _searchFocused && searchQuery.isEmpty;
        final filteredItems = _filterItems(state.items);
        return BrowseScaffold(
          header: Column(
            children: [
              BrowseTopSearchBar(
                hint: '搜索话题、活动、兴趣圈',
                editable: true,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: (v) => _onSearchSubmitted(v),
                onClear: _clearSearch,
                onRightActionTap: _quickRefresh,
                rightIcon: _quickRefreshing ? Icons.hourglass_top_rounded : Icons.refresh_rounded,
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
                                  '已筛选关键词: $searchQuery（找到 ${filteredItems.length} 条）',
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
                selectedIndex: _tab,
                onSelected: (i) {
                  _searchFocusNode.unfocus();
                  if (_scrollController.hasClients) {
                    _tabScrollOffsets[_tab] = _scrollController.offset;
                  }
                  setState(() => _tab = i);
                  _saveUiPrefs();
                  _controller.switchTab(i);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_scrollController.hasClients) return;
                    final target = (_tabScrollOffsets[i] ?? 0).clamp(
                      0,
                      _scrollController.position.maxScrollExtent,
                    );
                    _scrollController.animateTo(
                      target.toDouble(),
                      duration: liteMode ? t.motionFast : t.motionNormal,
                      curve: Curves.easeOutCubic,
                    );
                  });
                },
              ),
            ],
          ),
          body: AnimatedSwitcher(
            duration: liteMode ? t.motionFast : t.motionNormal,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: state.isLoading
                ? const AppLoadingSkeleton(key: ValueKey('discover-loading'), lines: 8)
                : state.error != null
                    ? AppErrorState(
                        key: const ValueKey('discover-error'),
                        title: '发现加载失败',
                        description: state.error!,
                        retryLabel: '重新加载',
                        onRetry: _controller.loadInitial,
                      )
                    : RefreshIndicator(
                        key: ValueKey('discover-data-$_tab-${searchQuery.isEmpty ? "none" : "query"}'),
                        onRefresh: _controller.loadInitial,
                        child: state.items.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 72),
                                  AppEmptyState(
                                    title: '暂无发现内容',
                                    description: '当前分类暂时没有可展示内容，稍后再试。',
                                    actionLabel: '重新加载',
                                    onAction: _controller.loadInitial,
                                  ),
                                ],
                              )
                            : ListView(
                                controller: _scrollController,
                                cacheExtent: liteMode ? 480 : 1200,
                                padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                                children: [
                                  if (filteredItems.isEmpty) ...[
                                    const SizedBox(height: 72),
                                    AppEmptyState(
                                      title: '没有匹配内容',
                                      description: '换个关键词试试',
                                      actionLabel: '清除筛选',
                                      onAction: _clearSearch,
                                    ),
                                  ] else ...[
                                    _SceneEntryRow(
                                      onTap: (label) {
                                        _searchController.text = label;
                                        _searchController.selection = TextSelection.collapsed(offset: label.length);
                                        _onSearchChanged(label);
                                      },
                                    ),
                                    SizedBox(height: t.spacing.sm),
                                    _SectionTitle(title: '${_tabs[_tab]}发现'),
                                    SizedBox(height: t.spacing.sm),
                                    ...List.generate(filteredItems.length, (index) {
                                      final item = filteredItems[index];
                                      final scene = _sceneOf(_tabs[_tab], item, index);
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: t.spacing.sm),
                                        child: RepaintBoundary(
                                          child: _DiscoverCard(
                                            title: item.title,
                                            subtitle: item.summary,
                                            highlightQuery: searchQuery,
                                            accent: scene.accent,
                                            icon: scene.icon,
                                            cta: scene.cta,
                                            onTap: () {
                                              _rememberPreferredTag(item);
                                              context.push(
                                                '${AppRouteNames.contentDetail}/${item.id}',
                                                extra: item,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }),
                                    SizedBox(height: t.spacing.md),
                                    _SectionTitle(title: '你可能喜欢'),
                                    SizedBox(height: t.spacing.sm),
                                    _DiscoverGrid(feed: filteredItems, highlightQuery: searchQuery),
                                  ],
                                  if (state.isLoadingMore) ...[
                                    SizedBox(height: t.spacing.sm),
                                    const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                                  ],
                                ],
                              ),
                      ),
          ),
        );
      },
    );
  }

  List<HomeFeedEntity> _filterItems(List<HomeFeedEntity> items) {
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

  @override
  bool get wantKeepAlive => true;

}

class _DiscoverGrid extends StatelessWidget {
  const _DiscoverGrid({required this.feed, required this.highlightQuery});

  final List<HomeFeedEntity> feed;
  final String highlightQuery;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    if (feed.isEmpty) {
      return const SizedBox.shrink();
    }
    final items = feed.take(4).toList();
    while (items.length < 4) {
      items.add(items.last);
    }
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: t.spacing.sm,
      mainAxisSpacing: t.spacing.sm,
      childAspectRatio: 1.1,
      children: List.generate(4, (index) {
        final item = items[index];
        return RepaintBoundary(
          child: _MiniTopicCard(
            title: item.title,
            highlightQuery: highlightQuery,
            sub: '${item.author} · ${item.likes} 热度',
            onTap: () {
              context.push(
                '${AppRouteNames.contentDetail}/${item.id}',
                extra: item,
              );
            },
          ),
        );
      }),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: t.textPrimary,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _DiscoverCard extends StatelessWidget {
  const _DiscoverCard({
    required this.title,
    required this.subtitle,
    required this.highlightQuery,
    required this.accent,
    required this.icon,
    required this.cta,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final String highlightQuery;
  final Color accent;
  final IconData icon;
  final String cta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(t.spacing.cardPadding),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.browseBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: accent.withValues(alpha: 0.22),
                ),
                child: Icon(icon, color: accent),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HighlightText(
                      text: title,
                      query: highlightQuery,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                      highlightStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: t.brandPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                      ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      cta,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: accent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniTopicCard extends StatelessWidget {
  const _MiniTopicCard({
    required this.title,
    required this.highlightQuery,
    required this.sub,
    this.onTap,
  });
  final String title;
  final String highlightQuery;
  final String sub;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(t.spacing.sm),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.browseBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.blur_on_rounded, color: t.brandPrimary),
              SizedBox(height: t.spacing.xs),
              HighlightText(
                text: title,
                query: highlightQuery,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
                highlightStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.brandPrimary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              Text(
                sub,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SceneEntryRow extends StatelessWidget {
  const _SceneEntryRow({required this.onTap});

  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scenes = const [
      ('同城活动', Icons.location_on_rounded),
      ('热点话题', Icons.local_fire_department_rounded),
      ('语音房', Icons.mic_rounded),
      ('兴趣圈', Icons.auto_awesome_rounded),
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scenes.length,
        separatorBuilder: (_, index) => SizedBox(width: t.spacing.xs),
        itemBuilder: (context, index) {
          final item = scenes[index];
          return AppChoiceChip(
            label: item.$1,
            leading: Icon(item.$2),
            onTap: () => onTap(item.$1),
          );
        },
      ),
    );
  }
}

class _DiscoverSceneStyle {
  const _DiscoverSceneStyle({
    required this.accent,
    required this.icon,
    required this.cta,
  });

  final Color accent;
  final IconData icon;
  final String cta;
}

_DiscoverSceneStyle _sceneOf(String tab, HomeFeedEntity item, int index) {
  final text = '${item.title} ${item.summary}'.toLowerCase();
  if (tab.contains('同城') || text.contains('同城') || text.contains('附近')) {
    return const _DiscoverSceneStyle(
      accent: Color(0xFF5FC8FF),
      icon: Icons.location_on_rounded,
      cta: '去看看',
    );
  }
  if (tab.contains('活动') || text.contains('活动') || text.contains('报名')) {
    return const _DiscoverSceneStyle(
      accent: Color(0xFF7BD88F),
      icon: Icons.event_available_rounded,
      cta: '立即报名',
    );
  }
  if (tab.contains('话题') || text.contains('话题') || text.contains('讨论')) {
    return const _DiscoverSceneStyle(
      accent: Color(0xFF9B8CFF),
      icon: Icons.forum_rounded,
      cta: '参与讨论',
    );
  }
  if (tab.contains('直播') || text.contains('直播') || text.contains('语音')) {
    return const _DiscoverSceneStyle(
      accent: Color(0xFFFFA76A),
      icon: Icons.mic_rounded,
      cta: '进入语音房',
    );
  }
  const fallback = [
    _DiscoverSceneStyle(accent: Color(0xFF7CB8FF), icon: Icons.explore_rounded, cta: '去看看'),
    _DiscoverSceneStyle(accent: Color(0xFF79D7C9), icon: Icons.auto_awesome_rounded, cta: '去看看'),
    _DiscoverSceneStyle(accent: Color(0xFF9A8CFF), icon: Icons.local_fire_department_rounded, cta: '参与讨论'),
    _DiscoverSceneStyle(accent: Color(0xFF7EA3FF), icon: Icons.groups_rounded, cta: '去看看'),
  ];
  return fallback[index % fallback.length];
}
