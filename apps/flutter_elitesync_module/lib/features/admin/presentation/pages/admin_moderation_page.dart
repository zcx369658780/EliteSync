import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';

class AdminModerationPage extends ConsumerWidget {
  const AdminModerationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminModerationProvider);
    final t = context.appTokens;

    return async.when(
      loading: () => const Scaffold(body: AppLoadingSkeleton(lines: 8)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          title: '运营后台加载失败',
          description: e.toString(),
          onRetry: () => ref.read(adminModerationProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        return BrowseScaffold(
          header: SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  '运营后台',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => ref.read(adminModerationProvider.notifier).refresh(),
                  icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
                ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              await ref.read(adminModerationProvider.notifier).refresh();
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: t.spacing.xs,
                bottom: t.spacing.huge,
              ),
              children: [
                const SectionReveal(
                  child: PageTitleRail(
                    title: '运营后台',
                    subtitle: '举报处理与用户治理',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                _OverviewCards(state: state),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 50),
                  child: _ReportSection(
                    reports: state.reports,
                    onOpen: (id) => context.push(
                      '${AppRouteNames.adminModerationReportDetail}/$id',
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 100),
                  child: _VerificationShortcut(
                    count: state.verifyQueue.length,
                    onOpen: () => context.push(AppRouteNames.adminVerification),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 150),
                  child: _UsersShortcut(
                    count: state.users.length,
                    onOpen: () => context.push(AppRouteNames.adminUsers),
                  ),
                ),
                if ((state.error ?? '').isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  AppErrorState(
                    title: '后台状态异常',
                    description: state.error!,
                    retryLabel: '重新加载',
                    onRetry: () => ref.read(adminModerationProvider.notifier).refresh(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OverviewCards extends StatelessWidget {
  const _OverviewCards({required this.state});

  final AdminModerationDashboardState state;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    Widget card(String label, String value, IconData icon) {
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

    return Row(
      children: [
        card('举报', '${state.reports.length}', Icons.report_outlined),
        SizedBox(width: t.spacing.sm),
        card('审核队列', '${state.verifyQueue.length}', Icons.verified_outlined),
        SizedBox(width: t.spacing.sm),
        card('用户', '${state.users.length}', Icons.people_outline),
      ],
    );
  }
}

class _VerificationShortcut extends StatelessWidget {
  const _VerificationShortcut({required this.count, required this.onOpen});

  final int count;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_user_outlined, size: 18, color: t.brandPrimary),
                  const SizedBox(width: 8),
                  Text(
                    '认证审核',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count 待审',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                '独立审核入口，适合快速处理认证队列。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: t.spacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppChoiceChip(
                  label: '打开审核页',
                  selected: false,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportSection extends StatelessWidget {
  const _ReportSection({required this.reports, required this.onOpen});

  final List<AdminModerationReportEntity> reports;
  final ValueChanged<int> onOpen;

  String _brief(AdminModerationReportEntity item) {
    final detail = item.detail.trim();
    if (detail.isEmpty) return '暂无详细描述';
    return detail.length <= 48 ? detail : '${detail.substring(0, 48)}...';
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.report_gmailerrorred_outlined,
                size: 18,
                color: t.brandPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                '举报处理',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '查看举报、跟进状态并进入详情处理。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          if (reports.isEmpty)
            Text(
              '暂无举报。',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            )
          else
            ...reports.take(6).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(t.radius.lg),
                  onTap: () => onOpen(item.id),
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppChoiceChip(
                              label: item.category.isEmpty
                                  ? '未分类'
                                  : item.category,
                              selected: true,
                            ),
                            AppChoiceChip(label: item.status, selected: false),
                            if (item.appealStatus.isNotEmpty)
                              AppChoiceChip(
                                label: '申诉 ${item.appealStatus}',
                                selected: false,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${item.reporter.name.isNotEmpty ? item.reporter.name : '匿名'} → ${item.targetUser.name.isNotEmpty ? item.targetUser.name : '目标用户 #${item.targetUser.id ?? 0}'}',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _brief(item),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _UsersShortcut extends StatelessWidget {
  const _UsersShortcut({required this.count, required this.onOpen});

  final int count;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.lg),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.people_outline, size: 18, color: t.brandPrimary),
                  const SizedBox(width: 8),
                  Text(
                    '用户列表',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$count 用户',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                '查看审核状态、画像状态与封禁记录。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
              SizedBox(height: t.spacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: AppChoiceChip(
                  label: '打开用户列表',
                  selected: false,
                  onTap: onOpen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

