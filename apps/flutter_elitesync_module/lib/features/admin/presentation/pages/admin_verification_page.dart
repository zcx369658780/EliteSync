import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';

class AdminVerificationPage extends ConsumerWidget {
  const AdminVerificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(adminModerationProvider);
    final t = context.appTokens;

    return async.when(
      loading: () => const Scaffold(body: AppLoadingSkeleton(lines: 8)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          title: '认证审核加载失败',
          description: e.toString(),
          onRetry: () => ref.read(adminModerationProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        return AppScaffold(
          appBar: const AppTopBar(
            title: '认证审核',
            mode: AppTopBarMode.backTitle,
          ),
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
                    title: '认证审核',
                    subtitle: '人工审核队列，保持与 canonical 匹配链路隔离',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                _OverviewRow(state: state),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 50),
                  child: _VerifyList(
                    items: state.verifyQueue,
                    onSetVerify: (userId, status) async {
                      await ref
                          .read(adminModerationProvider.notifier)
                          .updateVerify(userId: userId, status: status);
                      await ref.read(adminModerationProvider.notifier).refresh();
                      if (context.mounted) {
                        AppFeedback.showSuccess(context, '已更新审核状态：$status');
                      }
                    },
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

class _OverviewRow extends StatelessWidget {
  const _OverviewRow({required this.state});

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
        card('待审核', '${state.verifyQueue.length}', Icons.verified_user_outlined),
        SizedBox(width: t.spacing.sm),
        card('举报', '${state.reports.length}', Icons.report_outlined),
        SizedBox(width: t.spacing.sm),
        card('用户', '${state.users.length}', Icons.people_outline),
      ],
    );
  }
}

class _VerifyList extends StatelessWidget {
  const _VerifyList({required this.items, required this.onSetVerify});

  final List<AdminModerationUserEntity> items;
  final Future<void> Function(int userId, String status) onSetVerify;

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
              Icon(Icons.verified_user_outlined, size: 18, color: t.brandPrimary),
              const SizedBox(width: 8),
              Text(
                '审核队列',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: t.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '保留人工审核入口，后续可接真实认证。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          if (items.isEmpty)
            Text(
              '暂无待审核用户。',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
            )
          else
            ...items.take(10).map(
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
                        '${item.name.isNotEmpty ? item.name : '用户 #${item.id}'} · ${item.phone}',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '审核状态：${item.verifyStatus} · 画像状态：${item.moderationStatus}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppChoiceChip(label: '通过', selected: false, onTap: () => onSetVerify(item.id, 'approved')),
                          AppChoiceChip(label: '驳回', selected: false, onTap: () => onSetVerify(item.id, 'rejected')),
                          AppChoiceChip(label: '待审', selected: false, onTap: () => onSetVerify(item.id, 'pending')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

