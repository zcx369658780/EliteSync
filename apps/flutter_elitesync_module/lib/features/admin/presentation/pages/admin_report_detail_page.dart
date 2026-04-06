import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';

class AdminReportDetailPage extends ConsumerStatefulWidget {
  const AdminReportDetailPage({super.key, required this.reportId});

  final int reportId;

  @override
  ConsumerState<AdminReportDetailPage> createState() =>
      _AdminReportDetailPageState();
}

class _AdminReportDetailPageState extends ConsumerState<AdminReportDetailPage> {
  final TextEditingController _noteController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _action(String action, {String? note}) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref
          .read(adminModerationProvider.notifier)
          .actionReport(reportId: widget.reportId, action: action, note: note);
      ref.invalidate(adminModerationReportDetailProvider(widget.reportId));
      ref.invalidate(adminModerationProvider);
      if (!mounted) return;
      AppFeedback.showSuccess(context, '已提交操作：$action');
    } catch (e) {
      if (!mounted) return;
      AppFeedback.showError(context, '操作失败：$e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(
      adminModerationReportDetailProvider(widget.reportId),
    );
    final t = context.appTokens;

    return AppScaffold(
      appBar: const AppTopBar(title: '举报详情', mode: AppTopBarMode.backTitle),
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 8),
        error: (e, _) => AppErrorState(
          title: '举报详情加载失败',
          description: e.toString(),
          onRetry: () => ref.invalidate(
            adminModerationReportDetailProvider(widget.reportId),
          ),
        ),
        data: (report) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(
                adminModerationReportDetailProvider(widget.reportId),
              );
              await ref.read(
                adminModerationReportDetailProvider(widget.reportId).future,
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                top: t.spacing.xs,
                bottom: t.spacing.huge,
              ),
              children: [
                _SummaryCard(report: report),
                SizedBox(height: t.spacing.sm),
                _MetaCard(report: report),
                SizedBox(height: t.spacing.sm),
                _NoteCard(controller: _noteController, hint: '填写处理备注，可选。'),
                SizedBox(height: t.spacing.sm),
                _ActionCard(
                  submitting: _submitting,
                  controller: _noteController,
                  onAction: _action,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.report});

  final AdminModerationReportEntity report;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '举报 #${report.id}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChoiceChip(label: report.category, selected: true),
              AppChoiceChip(label: report.status, selected: false),
              if (report.appealStatus.isNotEmpty)
                AppChoiceChip(
                  label: '申诉 ${report.appealStatus}',
                  selected: false,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '举报人：${report.reporter.name.isNotEmpty ? report.reporter.name : '匿名'} · ${report.reporter.phone}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '对象：${report.targetUser.name.isNotEmpty ? report.targetUser.name : '未知用户'} · ${report.targetUser.phone}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            report.detail.isEmpty ? '暂无详细说明' : report.detail,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: t.textPrimary, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.report});

  final AdminModerationReportEntity report;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    Widget kv(String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 88,
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textPrimary,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '处理信息',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          kv('原因码', report.reasonCode.isEmpty ? '未填写' : report.reasonCode),
          kv('申诉说明', report.appealNote.isEmpty ? '无' : report.appealNote),
          kv('管理员备注', report.adminNote.isEmpty ? '无' : report.adminNote),
          kv('申诉时间', report.appealedAt?.toIso8601String() ?? '未填写'),
          kv('处理时间', report.resolvedAt?.toIso8601String() ?? '未处理'),
          kv(
            '处理人',
            report.resolver.name.isEmpty ? '未处理' : report.resolver.name,
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '处理备注',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          AppTextField(
            controller: controller,
            hint: hint,
            maxLength: 2000,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.submitting,
    required this.controller,
    required this.onAction,
  });

  final bool submitting;
  final TextEditingController controller;
  final Future<void> Function(String action, {String? note}) onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '处理动作',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: t.textPrimary,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppChoiceChip(
                label: '受理',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('triage', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '调查',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('investigate', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '驳回',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('dismiss', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '限制',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('restrict', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '封禁',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('banned', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '恢复',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('restore', note: controller.text.trim());
                      },
              ),
              AppChoiceChip(
                label: '关闭',
                selected: false,
                onTap: submitting
                    ? null
                    : () {
                        onAction('close', note: controller.text.trim());
                      },
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          AppPrimaryButton(
            label: submitting ? '处理中...' : '提交当前备注并执行受理',
            isLoading: submitting,
            onPressed: submitting
                ? null
                : () {
                    onAction('triage', note: controller.text.trim());
                  },
          ),
        ],
      ),
    );
  }
}


