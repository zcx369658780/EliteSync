import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';

class AdminDashboardPage extends ConsumerWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminModerationProvider);
    final t = context.appTokens;

    return async.when(
      loading: () => const Scaffold(body: AppLoadingSkeleton(lines: 8)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          title: '运营看板加载失败',
          description: e.toString(),
          onRetry: () => ref.read(adminModerationProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        final total = state.users.length;
        final disabled = state.users.where((u) => u.disabled).length;
        final synthetic = state.users.where((u) => u.isSynthetic).length;
        final pendingVerify = state.verifyQueue.length;
        final pendingReports = state.reports.where((r) => r.status == 'pending').length;
        final resolvedReports = state.reports.where((r) => r.status == 'resolved').length;

        Widget statCard(String label, String value, IconData icon) {
          return Expanded(
            child: AppCard(
              padding: EdgeInsets.all(t.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 18, color: t.brandPrimary),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        return AppScaffold(
          appBar: const AppTopBar(title: '运营看板', mode: AppTopBarMode.backTitle),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(adminModerationProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
              children: [
                const SectionReveal(
                  child: PageTitleRail(
                    title: '运营看板',
                    subtitle: '最小指标概览与治理入口',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                Row(
                  children: [
                    statCard('总用户', '$total', Icons.people_outline),
                    SizedBox(width: t.spacing.sm),
                    statCard('待审', '$pendingVerify', Icons.verified_user_outlined),
                    SizedBox(width: t.spacing.sm),
                    statCard('封禁', '$disabled', Icons.block_outlined),
                  ],
                ),
                SizedBox(height: t.spacing.md),
                Row(
                  children: [
                    statCard('待处理举报', '$pendingReports', Icons.report_outlined),
                    SizedBox(width: t.spacing.sm),
                    statCard('已处理举报', '$resolvedReports', Icons.check_circle_outline),
                    SizedBox(width: t.spacing.sm),
                    statCard('合成用户', '$synthetic', Icons.auto_awesome_outlined),
                  ],
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 40),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.admin_panel_settings_outlined, size: 18, color: t.brandPrimary),
                            const SizedBox(width: 8),
                            Text(
                              '治理入口',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: t.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '从这里进入举报处理、认证审核和用户列表。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: t.spacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppChoiceChip(
                              label: '运营后台',
                              selected: false,
                              onTap: () => context.push(AppRouteNames.adminModeration),
                            ),
                            AppChoiceChip(
                              label: '认证审核',
                              selected: false,
                              onTap: () => context.push(AppRouteNames.adminVerification),
                            ),
                            AppChoiceChip(
                              label: '用户列表',
                              selected: false,
                              onTap: () => context.push(AppRouteNames.adminUsers),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 80),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.report_outlined, size: 18, color: t.brandPrimary),
                            const SizedBox(width: 8),
                            Text(
                              '最新举报',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: t.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '保留最小概览，避免运营主页继续膨胀。',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: t.spacing.sm),
                        if (state.reports.isEmpty)
                          Text(
                            '暂无举报。',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
                          )
                        else
                          ...state.reports.take(4).map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: t.browseSurface,
                                  borderRadius: BorderRadius.circular(t.radius.lg),
                                  border: Border.all(color: t.browseBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.category.isEmpty ? '未分类' : item.category} · ${item.status}',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.reporter.name.isNotEmpty ? item.reporter.name : '匿名'} → ${item.targetUser.name.isNotEmpty ? item.targetUser.name : '目标用户'}',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}


