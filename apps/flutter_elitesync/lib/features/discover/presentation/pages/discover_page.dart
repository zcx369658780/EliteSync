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
import 'package:flutter_elitesync/features/discover/presentation/controllers/discover_feed_controller.dart';
import 'package:flutter_elitesync/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/presentation/providers/home_provider.dart';

class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  int _tab = 0;
  static const _tabs = ['热门', '同城', '活动', '话题', '直播'];
  final ScrollController _scrollController = ScrollController();
  late final DiscoverFeedController _controller;

  @override
  void initState() {
    super.initState();
    final remote = ref.read(homeRemoteDataSourceProvider);
    _controller = DiscoverFeedController(
      remote: remote,
      mapper: const HomeMapper(),
    )..addListener(_onControllerChanged);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.initialize());
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 220) {
      _controller.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final state = _controller.state;
    return BrowseScaffold(
      header: Column(
        children: [
          const BrowseTopSearchBar(hint: '搜索话题、活动、兴趣圈'),
          SizedBox(height: t.spacing.sm),
          CategoryTabStrip(
            tabs: _tabs,
            selectedIndex: _tab,
            onSelected: (i) {
              setState(() => _tab = i);
              _controller.switchTab(i);
            },
          ),
        ],
      ),
      body: state.isLoading
          ? const AppLoadingSkeleton(lines: 8)
          : state.error != null
              ? AppErrorState(
                  title: '发现加载失败',
                  description: state.error!,
                  onRetry: _controller.loadInitial,
                )
              : RefreshIndicator(
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
                          padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                          children: [
                            _SectionTitle(title: '${_tabs[_tab]}发现'),
                            SizedBox(height: t.spacing.sm),
                            ...List.generate(state.items.length, (index) {
                              final item = state.items[index];
                              final accents = const [
                                Color(0xFF7CB8FF),
                                Color(0xFF79D7C9),
                                Color(0xFF9A8CFF),
                                Color(0xFF7EA3FF),
                              ];
                              return Padding(
                                padding: EdgeInsets.only(bottom: t.spacing.sm),
                                child: _DiscoverCard(
                                  title: item.title,
                                  subtitle: item.summary,
                                  accent: accents[index % accents.length],
                                  onTap: () {
                                    context.push(
                                      '${AppRouteNames.contentDetail}/${item.id}',
                                      extra: item,
                                    );
                                  },
                                ),
                              );
                            }),
                            SizedBox(height: t.spacing.md),
                            _SectionTitle(title: '你可能喜欢'),
                            SizedBox(height: t.spacing.sm),
                            _DiscoverGrid(feed: state.items),
                            if (state.isLoadingMore) ...[
                              SizedBox(height: t.spacing.sm),
                              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                            ],
                          ],
                        ),
                ),
    );
  }
}

class _DiscoverGrid extends StatelessWidget {
  const _DiscoverGrid({required this.feed});

  final List<HomeFeedEntity> feed;

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
        return _MiniTopicCard(
          title: item.title,
          sub: '${item.author} · ${item.likes} 热度',
          onTap: () {
            context.push(
              '${AppRouteNames.contentDetail}/${item.id}',
              extra: item,
            );
          },
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
    required this.accent,
    this.onTap,
  });
  final String title;
  final String subtitle;
  final Color accent;
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
                child: Icon(Icons.auto_awesome_rounded, color: accent),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
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
  const _MiniTopicCard({required this.title, required this.sub, this.onTap});
  final String title;
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
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w700,
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
