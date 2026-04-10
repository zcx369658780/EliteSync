import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/admin/domain/entities/admin_moderation_entities.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/providers/admin_moderation_provider.dart';

class AdminUsersPage extends ConsumerStatefulWidget {
  const AdminUsersPage({super.key});

  @override
  ConsumerState<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends ConsumerState<AdminUsersPage> {
  final TextEditingController _queryController = TextEditingController();
  String _filter = 'all';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  List<AdminModerationUserEntity> _filtered(
    List<AdminModerationUserEntity> items,
  ) {
    final query = _queryController.text.trim().toLowerCase();
    return items.where((item) {
      final matchQuery =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.phone.toLowerCase().contains(query) ||
          item.moderationStatus.toLowerCase().contains(query) ||
          item.verifyStatus.toLowerCase().contains(query) ||
          item.accountType.toLowerCase().contains(query) ||
          item.syntheticBatch.toLowerCase().contains(query) ||
          item.syntheticBatchId.toLowerCase().contains(query) ||
          item.generationVersion.toLowerCase().contains(query) ||
          item.accountStatus.toLowerCase().contains(query) ||
          item.visibilityScope.toLowerCase().contains(query) ||
          (item.syntheticSeed?.toString().contains(query) ?? false);
      final matchFilter = switch (_filter) {
        'disabled' => item.disabled,
        'normal' => item.accountType == 'normal',
        'test' => item.accountType == 'test',
        'synthetic' => item.isSynthetic,
        'matchable' => item.isMatchEligible,
        'square' => item.isSquareVisible,
        'metrics' => item.excludeFromMetrics,
        'pending' => item.verifyStatus == 'pending',
        'approved' => item.verifyStatus == 'approved',
        'rejected' => item.verifyStatus == 'rejected',
        _ => true,
      };
      return matchQuery && matchFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(adminModerationProvider);
    final t = context.appTokens;

    return async.when(
      loading: () => const Scaffold(body: AppLoadingSkeleton(lines: 8)),
      error: (e, _) => Scaffold(
        body: AppErrorState(
          title: '用户列表加载失败',
          description: e.toString(),
          onRetry: () => ref.read(adminModerationProvider.notifier).refresh(),
        ),
      ),
      data: (state) {
        final items = _filtered(state.users);
        return AppScaffold(
          appBar: const AppTopBar(title: '用户列表', mode: AppTopBarMode.backTitle),
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
                    title: '用户列表',
                    subtitle: '查看审核状态、画像状态与封禁记录',
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                _OverviewRow(state: state),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 40),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '筛选',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        SizedBox(height: t.spacing.sm),
                        AppTextField(
                          controller: _queryController,
                          hint: '搜索姓名、手机号、状态、批次',
                          prefixIcon: const Icon(Icons.search_rounded),
                          onChanged: (_) => setState(() {}),
                          onClear: () {
                            _queryController.clear();
                            setState(() {});
                          },
                        ),
                        SizedBox(height: t.spacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppChoiceChip(
                              label: '全部',
                              selected: _filter == 'all',
                              onTap: () => setState(() => _filter = 'all'),
                            ),
                            AppChoiceChip(
                              label: '普通用户',
                              selected: _filter == 'normal',
                              onTap: () => setState(() => _filter = 'normal'),
                            ),
                            AppChoiceChip(
                              label: '测试账号',
                              selected: _filter == 'test',
                              onTap: () => setState(() => _filter = 'test'),
                            ),
                            AppChoiceChip(
                              label: '已封禁',
                              selected: _filter == 'disabled',
                              onTap: () => setState(() => _filter = 'disabled'),
                            ),
                            AppChoiceChip(
                              label: '合成用户',
                              selected: _filter == 'synthetic',
                              onTap: () =>
                                  setState(() => _filter = 'synthetic'),
                            ),
                            AppChoiceChip(
                              label: '可匹配',
                              selected: _filter == 'matchable',
                              onTap: () =>
                                  setState(() => _filter = 'matchable'),
                            ),
                            AppChoiceChip(
                              label: '广场可见',
                              selected: _filter == 'square',
                              onTap: () => setState(() => _filter = 'square'),
                            ),
                            AppChoiceChip(
                              label: '排除指标',
                              selected: _filter == 'metrics',
                              onTap: () => setState(() => _filter = 'metrics'),
                            ),
                            AppChoiceChip(
                              label: '待审',
                              selected: _filter == 'pending',
                              onTap: () => setState(() => _filter = 'pending'),
                            ),
                            AppChoiceChip(
                              label: '已通过',
                              selected: _filter == 'approved',
                              onTap: () => setState(() => _filter = 'approved'),
                            ),
                            AppChoiceChip(
                              label: '已驳回',
                              selected: _filter == 'rejected',
                              onTap: () => setState(() => _filter = 'rejected'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 70),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline,
                              size: 18,
                              color: t.brandPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '用户明细',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: t.textPrimary,
                                  ),
                            ),
                            const Spacer(),
                            Text(
                              '${items.length} 条',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: t.textSecondary),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '用于核对账号状态、画像状态和认证审核进度。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                        SizedBox(height: t.spacing.sm),
                        if (items.isEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: t.spacing.lg,
                            ),
                            child: Text(
                              '没有符合筛选条件的用户。',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: t.textSecondary),
                            ),
                          )
                        else
                          ...items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: t.browseSurface,
                                  borderRadius: BorderRadius.circular(
                                    t.radius.lg,
                                  ),
                                  border: Border.all(color: t.browseBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.name.isNotEmpty ? item.name : '用户 #${item.id}'} · ${item.phone}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            color: t.textPrimary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '审核：${item.verifyStatus} · 画像：${item.moderationStatus} · ${item.isSynthetic ? '合成用户' : '真实用户'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: t.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '类型：${item.accountType} · ${item.isMatchEligible ? '可匹配' : '不可匹配'} · ${item.isSquareVisible ? '广场可见' : '广场隐藏'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(color: t.textSecondary),
                                    ),
                                    if (item.syntheticBatch.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '批次：${item.syntheticBatch}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: t.textSecondary),
                                      ),
                                    ],
                                    if (item.isSynthetic ||
                                        item.syntheticBatchId.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          if (item.syntheticBatchId.isNotEmpty)
                                            _InfoChip(
                                              label: 'Batch',
                                              value: item.syntheticBatchId,
                                            ),
                                          _InfoChip(
                                            label: 'Type',
                                            value: item.accountType,
                                          ),
                                          _InfoChip(
                                            label: 'Version',
                                            value: item.generationVersion,
                                          ),
                                          _InfoChip(
                                            label: 'Scope',
                                            value: item.visibilityScope,
                                          ),
                                          _InfoChip(
                                            label: 'Status',
                                            value: item.accountStatus,
                                          ),
                                          _InfoChip(
                                            label: 'Match',
                                            value: item.isMatchEligible
                                                ? 'yes'
                                                : 'no',
                                          ),
                                          _InfoChip(
                                            label: 'Square',
                                            value: item.isSquareVisible
                                                ? 'yes'
                                                : 'no',
                                          ),
                                          _InfoChip(
                                            label: 'Metrics',
                                            value: item.excludeFromMetrics
                                                ? 'off'
                                                : 'on',
                                          ),
                                          if (item.syntheticSeed != null)
                                            _InfoChip(
                                              label: 'Seed',
                                              value: '${item.syntheticSeed}',
                                            ),
                                        ],
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: [
                                        if (!item.disabled)
                                          AppChoiceChip(
                                            label: '封禁',
                                            selected: false,
                                            onTap: () async {
                                              await ref
                                                  .read(
                                                    adminModerationProvider
                                                        .notifier,
                                                  )
                                                  .disableUser(userId: item.id);
                                              await ref
                                                  .read(
                                                    adminModerationProvider
                                                        .notifier,
                                                  )
                                                  .refresh();
                                              if (context.mounted) {
                                                AppFeedback.showSuccess(
                                                  context,
                                                  '已封禁用户 #${item.id}',
                                                );
                                              }
                                            },
                                          )
                                        else
                                          AppChoiceChip(
                                            label: '已封禁',
                                            selected: true,
                                          ),
                                      ],
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

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.pill),
        border: Border.all(color: t.browseBorder),
      ),
      child: Text(
        '$label: $value',
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
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
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            card('总用户', '${state.users.length}', Icons.people_outline),
            SizedBox(width: t.spacing.sm),
            card(
              '普通用户',
              '${state.users.where((u) => u.accountType == 'normal').length}',
              Icons.person_outline,
            ),
            SizedBox(width: t.spacing.sm),
            card(
              '测试账号',
              '${state.users.where((u) => u.accountType == 'test').length}',
              Icons.science_outlined,
            ),
          ],
        ),
        SizedBox(height: t.spacing.sm),
        Row(
          children: [
            card(
              '合成用户',
              '${state.users.where((u) => u.isSynthetic).length}',
              Icons.bolt_outlined,
            ),
            SizedBox(width: t.spacing.sm),
            card(
              '广场可见',
              '${state.users.where((u) => u.isSquareVisible).length}',
              Icons.visibility_outlined,
            ),
            SizedBox(width: t.spacing.sm),
            card(
              '排除指标',
              '${state.users.where((u) => u.excludeFromMetrics).length}',
              Icons.analytics_outlined,
            ),
          ],
        ),
        SizedBox(height: t.spacing.xs),
        Text(
          '统计口径：测试账号按 account_type = test 统计；合成用户按 is_synthetic = true 统计。两者可以重叠，所以计数不会互斥。',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: t.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
