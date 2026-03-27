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
import 'package:flutter_elitesync/features/chat/domain/entities/conversation_entity.dart';
import 'package:flutter_elitesync/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync/features/chat/presentation/widgets/conversation_list_item.dart';

class ConversationListPage extends ConsumerStatefulWidget {
  const ConversationListPage({super.key});

  @override
  ConsumerState<ConversationListPage> createState() => _ConversationListPageState();
}

class _ConversationListPageState extends ConsumerState<ConversationListPage> {
  int _tabIndex = 0;
  static const _tabs = ['全部', '未读', '已读'];

  List<ConversationEntity> _applyFilter(List<ConversationEntity> input) {
    if (_tabIndex == 1) return input.where((e) => e.unread > 0).toList();
    if (_tabIndex == 2) return input.where((e) => e.unread == 0).toList();
    return input;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(conversationListProvider);
    return async.when(
      loading: () => const AppLoadingSkeleton(lines: 7),
      error: (e, _) => AppErrorState(title: '会话加载失败', description: e.toString()),
      data: (state) {
        if ((state.error ?? '').isNotEmpty) {
          return AppErrorState(title: '会话加载失败', description: state.error!);
        }
        final t = context.appTokens;
        final filtered = _applyFilter(state.items);
        return BrowseScaffold(
          header: Column(
            children: [
              const BrowseTopSearchBar(hint: '搜索会话、昵称、关键词'),
              SizedBox(height: t.spacing.sm),
              CategoryTabStrip(
                tabs: _tabs,
                selectedIndex: _tabIndex,
                onSelected: (index) => setState(() => _tabIndex = index),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(conversationListProvider);
              await ref.read(conversationListProvider.future);
            },
            child: filtered.isEmpty
                ? ListView(
                    children: const [
                      SizedBox(height: 80),
                      AppEmptyState(
                        title: '暂无会话',
                        description: '当你和对方互相确认意向后，会在这里开始聊天',
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: EdgeInsets.only(top: t.spacing.xs, bottom: t.spacing.huge),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => SizedBox(height: t.spacing.xs),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          color: t.browseSurface,
                          borderRadius: BorderRadius.circular(t.radius.lg),
                          border: Border.all(color: t.browseBorder),
                        ),
                        child: ConversationListItem(
                          item: item,
                          onTap: () => context.push(
                            '${AppRouteNames.chatRoom}/${item.id}',
                            extra: item.name,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
