import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/browse_top_search_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/category_tab_strip.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/widgets/conversation_list_item.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage>
    with AutomaticKeepAliveClientMixin<ConversationListPage> {
  int _tabIndex = 0;
  final ValueNotifier<String> _searchQueryNotifier = ValueNotifier<String>('');
  bool _quickUnreadOnly = false;
  static const _tabs = ['全部', '未读', '已读'];
  final ScrollController _listController = ScrollController();
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  Timer? _searchUiDebounce;
  List<String> _recentSearches = const [];
  bool _searchFocused = false;
  bool _quickRefreshing = false;
  List<ConversationEntity> _snapshotItems = const [];
  bool _snapshotHydrated = false;
  final Map<int, double> _tabScrollOffsets = <int, double>{};
  List<ConversationEntity> _cachedSourceItems = const [];
  String _cachedFilterQuery = '';
  int _cachedTabIndex = 0;
  bool _cachedUnreadOnly = false;
  List<ConversationEntity> _cachedFilteredItems = const [];
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
    _loadUiPrefs();
    _loadSearchHistory();
    _loadConversationSnapshot();
  }

  Future<void> _loadUiPrefs() async {
    final local = ref.read(localStorageProvider);
    final savedTab = await local.getInt(CacheKeys.messagesSelectedTab);
    final unreadOnly = await local.getBool(CacheKeys.messagesQuickUnreadOnly);
    if (!mounted) return;
    setState(() {
      _tabIndex = (savedTab ?? 0).clamp(0, _tabs.length - 1);
      _quickUnreadOnly = unreadOnly ?? false;
    });
  }

  Future<void> _saveUiPrefs() async {
    final local = ref.read(localStorageProvider);
    await local.setInt(CacheKeys.messagesSelectedTab, _tabIndex);
    await local.setBool(CacheKeys.messagesQuickUnreadOnly, _quickUnreadOnly);
  }

  Future<void> _loadSearchHistory() async {
    final local = ref.read(localStorageProvider);
    final raw = await local.getString(CacheKeys.messagesSearchHistory);
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
    await ref.read(localStorageProvider).setString(CacheKeys.messagesSearchHistory, jsonEncode(next));
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
    _searchQueryNotifier.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _restoreScrollForTab(int tab) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_listController.hasClients) return;
      final raw = _tabScrollOffsets[tab] ?? 0;
      final target = raw.clamp(0, _listController.position.maxScrollExtent);
      final liteMode = ref.read(performanceLiteModeProvider).asData?.value ?? false;
      final t = context.appTokens;
      _listController.animateTo(
        target.toDouble(),
        duration: liteMode ? t.motionFast : t.motionNormal,
        curve: Curves.easeOutCubic,
      );
    });
  }

  List<ConversationEntity> _applyFilter(List<ConversationEntity> input) {
    final q = _searchQueryNotifier.value.trim().toLowerCase();
    if (identical(input, _cachedSourceItems) &&
        q == _cachedFilterQuery &&
        _tabIndex == _cachedTabIndex &&
        _quickUnreadOnly == _cachedUnreadOnly) {
      return _cachedFilteredItems;
    }
    _cachedSourceItems = input;
    _cachedFilterQuery = q;
    _cachedTabIndex = _tabIndex;
    _cachedUnreadOnly = _quickUnreadOnly;

    Iterable<ConversationEntity> current = input;
    final ids = input.map((e) => e.id).toSet();
    _searchIndex.removeWhere((key, _) => !ids.contains(key));
    for (final item in input) {
      _searchIndex.putIfAbsent(
        item.id,
        () => '${item.name} ${item.lastMessage}'.toLowerCase(),
      );
    }

    if (_quickUnreadOnly) {
      current = current.where((e) => e.unread > 0);
    } else {
      if (_tabIndex == 1) current = current.where((e) => e.unread > 0);
      if (_tabIndex == 2) current = current.where((e) => e.unread == 0);
    }

    if (q.isNotEmpty) {
      current = current.where((e) => (_searchIndex[e.id] ?? '').contains(q));
    }
    final filtered = current.toList();
    _cachedFilteredItems = filtered;
    return filtered;
  }

  Future<void> _quickRefresh() async {
    if (_quickRefreshing) return;
    setState(() => _quickRefreshing = true);
    try {
      ref.invalidate(conversationListProvider);
      final state = await ref.read(conversationListProvider.future);
      await _saveConversationSnapshot(state.items);
      if (!mounted) return;
      AppFeedback.showInfo(context, '已刷新会话列表');
    } finally {
      if (mounted) {
        setState(() => _quickRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final async = ref.watch(conversationListProvider);
    return async.when(
      loading: () => const AppLoadingSkeleton(lines: 7),
      error: (e, _) => AppErrorState(
        title: '会话加载失败',
        description: e.toString(),
        retryLabel: '重新加载',
        onRetry: () => ref.invalidate(conversationListProvider),
      ),
      data: (state) {
        final liteMode = ref.watch(performanceLiteModeProvider).asData?.value ?? false;
        if (state.items.isNotEmpty) {
          _snapshotItems = state.items;
          _snapshotHydrated = true;
          unawaited(_saveConversationSnapshot(state.items));
        }
        if ((state.error ?? '').isNotEmpty && !_snapshotHydrated) {
          return BrowseScaffold(
            header: const SizedBox.shrink(),
            body: ListView(
              children: [
                AppErrorState(
                  title: '会话加载失败',
                  description: state.error!,
                  retryLabel: '重新加载',
                  onRetry: () => ref.invalidate(conversationListProvider),
                ),
                const SizedBox(height: 8),
                AppEmptyState(
                  title: '当前没有可展示会话',
                  description: '你可以先去匹配页建立新关系，稍后会自动出现会话入口。',
                  actionLabel: '去匹配',
                  onAction: () => context.go(AppRouteNames.match),
                ),
              ],
            ),
          );
        }
        return ValueListenableBuilder<String>(
          valueListenable: _searchQueryNotifier,
          builder: (context, searchQuery, _) {
            final t = context.appTokens;
            final showRecentChips = _searchFocused && searchQuery.isEmpty;
            final sourceItems = state.items.isNotEmpty ? state.items : (_snapshotHydrated ? _snapshotItems : state.items);
            final filtered = _applyFilter(sourceItems);
            final hasAnyConversations = sourceItems.isNotEmpty;
            final hasActiveFilter = _quickUnreadOnly || _tabIndex != 0 || searchQuery.trim().isNotEmpty;
            return BrowseScaffold(
              header: Column(
                children: [
                  BrowseTopSearchBar(
                    hint: '搜索会话、昵称、关键词',
                    editable: true,
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: _onSearchChanged,
                    onSubmitted: (v) => _onSearchSubmitted(v),
                    onClear: _clearSearch,
                    onRightActionTap: _quickRefresh,
                    rightIcon: _quickRefreshing ? Icons.hourglass_top_rounded : Icons.refresh_rounded,
                  ),
                  SizedBox(height: t.spacing.xs),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '当前会话 ${filtered.length} 条',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: t.textSecondary,
                              ),
                        ),
                      ),
                      AppChoiceChip(
                        label: '去匹配',
                        leading: const Icon(Icons.favorite_rounded),
                        onTap: () => context.go(AppRouteNames.match),
                      ),
                    ],
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
                                      '已筛选关键词: $searchQuery（找到 ${filtered.length} 条）',
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
                  SizedBox(height: t.spacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AppChoiceChip(
                      selected: _quickUnreadOnly,
                      label: '仅未读',
                      onTap: () {
                        final v = !_quickUnreadOnly;
                        setState(() => _quickUnreadOnly = v);
                        _saveUiPrefs();
                        if (_listController.hasClients) {
                          _listController.animateTo(
                            0,
                            duration: liteMode ? t.motionFast : t.motionNormal,
                            curve: Curves.easeOutCubic,
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  CategoryTabStrip(
                    tabs: _tabs,
                    selectedIndex: _tabIndex,
                    onSelected: (index) => setState(() {
                      _searchFocusNode.unfocus();
                      if (_listController.hasClients) {
                        _tabScrollOffsets[_tabIndex] = _listController.offset;
                      }
                      _tabIndex = index;
                      _quickUnreadOnly = false;
                      _saveUiPrefs();
                      _restoreScrollForTab(index);
                    }),
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(conversationListProvider);
                  await ref.read(conversationListProvider.future);
                },
                child: AnimatedSwitcher(
                  duration: liteMode ? t.motionFast : t.motionNormal,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: filtered.isEmpty
                      ? ListView(
                          key: const ValueKey('messages-empty'),
                          children: [
                            const SizedBox(height: 80),
                            if (hasAnyConversations && hasActiveFilter)
                              AppEmptyState(
                                title: '没有符合当前筛选的会话',
                                description: '可尝试清空搜索词或切换到“全部”查看',
                                actionLabel: '清空筛选',
                                onAction: () {
                                  _quickUnreadOnly = false;
                                  _tabIndex = 0;
                                  _clearSearch();
                                  setState(() {});
                                },
                              )
                            else
                              AppEmptyState(
                                title: '暂无会话',
                                description: '当你和对方互相确认意向后，会在这里开始聊天',
                                actionLabel: '去看看匹配',
                                onAction: () => context.go(AppRouteNames.match),
                              ),
                          ],
                        )
                      : ListView.separated(
                          key: ValueKey('messages-list-$_tabIndex-${_quickUnreadOnly ? 1 : 0}-${searchQuery.isEmpty ? "none" : "query"}'),
                          controller: _listController,
                          cacheExtent: liteMode ? 480 : 1200,
                          padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                          itemCount: filtered.length,
                          separatorBuilder: (context, index) => SizedBox(height: t.spacing.xs),
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            return RepaintBoundary(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: t.browseSurface,
                                  borderRadius: BorderRadius.circular(t.radius.lg),
                                  border: Border.all(color: t.browseBorder),
                                ),
                                child: ConversationListItem(
                                  item: item,
                                  highlightQuery: searchQuery,
                                  onTap: () => context.push(
                                    '${AppRouteNames.chatRoom}/${item.id}',
                                    extra: item.name,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadConversationSnapshot() async {
    final raw = await ref.read(localStorageProvider).getString(CacheKeys.messagesConversationSnapshot);
    if (!mounted || raw == null || raw.isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final list = decoded
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => ConversationEntity(
              id: (e['id'] ?? '').toString(),
              name: (e['name'] ?? '').toString(),
              lastMessage: (e['lastMessage'] ?? '').toString(),
              lastTime: (e['lastTime'] ?? '').toString(),
              unread: (e['unread'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();
      if (list.isEmpty) return;
      setState(() {
        _snapshotItems = list;
        _snapshotHydrated = true;
      });
    } catch (_) {}
  }

  Future<void> _saveConversationSnapshot(List<ConversationEntity> items) async {
    if (items.isEmpty) return;
    final payload = items
        .map(
          (e) => {
            'id': e.id,
            'name': e.name,
            'lastMessage': e.lastMessage,
            'lastTime': e.lastTime,
            'unread': e.unread,
          },
        )
        .toList();
    await ref.read(localStorageProvider).setString(
          CacheKeys.messagesConversationSnapshot,
          jsonEncode(payload),
        );
  }

  @override
  bool get wantKeepAlive => true;

}
