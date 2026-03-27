import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/brand/browse_top_search_bar.dart';
import 'package:flutter_elitesync/design_system/components/brand/category_tab_strip.dart';
import 'package:flutter_elitesync/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/states/app_empty_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync/features/home/presentation/widgets/media_feed_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _selectedTabIndex = 0;
  static const _tabs = ['推荐', '附近', '话题', '活动', '灵感'];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncState = ref.watch(homeProvider);

    return asyncState.when(
      loading: () => const AppLoadingSkeleton(lines: 8),
      error: (e, _) => AppErrorState(
        title: '首页加载失败',
        description: e.toString(),
        onRetry: () => ref.read(homeProvider.notifier).refresh(),
      ),
      data: (state) {
        final t = context.appTokens;
        return BrowseScaffold(
          header: Column(
            children: [
              const BrowseTopSearchBar(hint: '搜索话题、活动、用户'),
              SizedBox(height: t.spacing.sm),
              CategoryTabStrip(
                tabs: _tabs,
                selectedIndex: _selectedTabIndex,
                onSelected: (index) {
                  setState(() => _selectedTabIndex = index);
                  const tabKeys = ['recommend', 'nearby', 'topic', 'event', 'inspire'];
                  ref.read(homeProvider.notifier).switchTab(tabKeys[index]);
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () => ref.read(homeProvider.notifier).refresh(),
            child: ListView(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(0, t.spacing.xs, 0, t.spacing.huge),
              children: [
                _ShortcutRow(
                  shortcuts: state.shortcuts,
                  onShortcutTap: (item) => _handleShortcutTap(context, item),
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
                if (state.feed.isEmpty)
                  const AppEmptyState(title: '暂无推荐', description: '完成问卷后将为你推荐更多内容')
                else
                  _MasonryFeed(
                    feed: state.feed,
                    onCardTap: (item) {
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
  }

  void _handleShortcutTap(BuildContext context, HomeShortcutEntity item) {
    final action = (item.action ?? '').trim().toLowerCase();
    final target = (item.target ?? '').trim();
    if (action == 'route' && target.isNotEmpty) {
      context.push(target);
      return;
    }

    switch (item.key) {
      case 'questionnaire':
        context.push(AppRouteNames.questionnaire);
        break;
      case 'mbti':
        context.push(AppRouteNames.mbtiCenter);
        break;
      case 'astro':
        context.push(AppRouteNames.astroProfile);
        break;
      case 'profile':
        context.push(AppRouteNames.editProfile);
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('入口「${item.title}」暂未配置')),
        );
    }
  }
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
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: shortcuts.length,
        separatorBuilder: (context, index) => SizedBox(width: t.spacing.xs),
        itemBuilder: (context, index) {
          final item = shortcuts[index];
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
  const _MasonryFeed({required this.feed, required this.onCardTap});

  final List<HomeFeedEntity> feed;
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
              child: MediaFeedCard(
                item: items[i],
                index: startIndex + i * 2,
                onTap: () => onCardTap(items[i]),
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
