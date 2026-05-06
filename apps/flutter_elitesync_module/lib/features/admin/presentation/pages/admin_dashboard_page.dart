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
        final testUsers = state.users
            .where((u) => u.accountType == 'test')
            .length;
        final excludedFromMetrics = state.users
            .where((u) => u.excludeFromMetrics)
            .length;
        final squareVisibleSynthetic = state.users
            .where((u) => u.isSynthetic && u.isSquareVisible)
            .length;
        final pendingVerify = state.verifyQueue.length;
        final pendingReports = state.reports
            .where((r) => r.status == 'pending')
            .length;
        final resolvedReports = state.reports
            .where((r) => r.status == 'resolved')
            .length;

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
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                  ),
                ],
              ),
            ),
          );
        }

        void showVerificationDetail({
          required String title,
          required String status,
          required String description,
          required List<String> checks,
          required String runbook,
          required String evidence,
        }) {
          showModalBottomSheet<void>(
            context: context,
            showDragHandle: true,
            isScrollControlled: true,
            builder: (sheetContext) {
              final sheetTokens = sheetContext.appTokens;
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    sheetTokens.spacing.lg,
                    0,
                    sheetTokens.spacing.lg,
                    sheetTokens.spacing.lg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$title · $status',
                        style: Theme.of(sheetContext).textTheme.titleMedium
                            ?.copyWith(
                              color: sheetTokens.textPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      SizedBox(height: sheetTokens.spacing.xs),
                      Text(
                        description,
                        style: Theme.of(sheetContext).textTheme.bodySmall
                            ?.copyWith(
                              color: sheetTokens.textSecondary,
                              height: 1.45,
                            ),
                      ),
                      SizedBox(height: sheetTokens.spacing.md),
                      Text(
                        '核验说明',
                        style: Theme.of(sheetContext).textTheme.titleSmall
                            ?.copyWith(
                              color: sheetTokens.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      SizedBox(height: sheetTokens.spacing.xs),
                      ...checks.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: sheetTokens.brandPrimary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  item,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: sheetTokens.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (runbook.isNotEmpty) ...[
                        SizedBox(height: sheetTokens.spacing.xs),
                        Text(
                          'Runbook：$runbook',
                          style: Theme.of(sheetContext).textTheme.bodySmall
                              ?.copyWith(
                                color: sheetTokens.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      if (evidence.isNotEmpty) ...[
                        SizedBox(height: sheetTokens.spacing.xxs),
                        Text(
                          '证据索引：$evidence',
                          style: Theme.of(sheetContext).textTheme.bodySmall
                              ?.copyWith(
                                color: sheetTokens.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                      SizedBox(height: sheetTokens.spacing.sm),
                      Text(
                        '禁止动作：不执行生产写库、不改 contract、不把待核验写成已通过。',
                        style: Theme.of(sheetContext).textTheme.bodySmall
                            ?.copyWith(
                              color: sheetTokens.error,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: sheetTokens.spacing.sm),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('知道了'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }

        Widget governanceRow({
          required IconData icon,
          required String title,
          required String description,
          required String status,
          List<String> checks = const [],
          String runbook = '',
          String evidence = '',
        }) {
          final hasDetail =
              checks.isNotEmpty || runbook.isNotEmpty || evidence.isNotEmpty;
          final radius = BorderRadius.circular(t.radius.lg);
          final row = Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.browseSurface,
              borderRadius: radius,
              border: Border.all(color: t.browseBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 18, color: t.brandPrimary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: t.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      if (hasDetail) ...[
                        const SizedBox(height: 6),
                        Text(
                          '查看核验说明',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: t.brandPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      status,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.brandPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (hasDetail) ...[
                      const SizedBox(height: 6),
                      Icon(
                        Icons.chevron_right,
                        size: 18,
                        color: t.textTertiary,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: radius,
                onTap: hasDetail
                    ? () => showVerificationDetail(
                        title: title,
                        status: status,
                        description: description,
                        checks: checks,
                        runbook: runbook,
                        evidence: evidence,
                      )
                    : null,
                child: row,
              ),
            ),
          );
        }

        Widget sectionTitle(IconData icon, String title, String subtitle) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: t.brandPrimary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: t.textPrimary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ],
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
                  child: PageTitleRail(title: '运营看板', subtitle: '最小指标概览与治理入口'),
                ),
                SizedBox(height: t.spacing.sm),
                Row(
                  children: [
                    statCard('总用户', '$total', Icons.people_outline),
                    SizedBox(width: t.spacing.sm),
                    statCard(
                      '待审',
                      '$pendingVerify',
                      Icons.verified_user_outlined,
                    ),
                    SizedBox(width: t.spacing.sm),
                    statCard('封禁', '$disabled', Icons.block_outlined),
                  ],
                ),
                SizedBox(height: t.spacing.md),
                Row(
                  children: [
                    statCard('待处理举报', '$pendingReports', Icons.report_outlined),
                    SizedBox(width: t.spacing.sm),
                    statCard(
                      '已处理举报',
                      '$resolvedReports',
                      Icons.check_circle_outline,
                    ),
                    SizedBox(width: t.spacing.sm),
                    statCard('合成用户', '$synthetic', Icons.auto_awesome_outlined),
                  ],
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 30),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.health_and_safety_outlined,
                          '5.4 只读运营准备',
                          '当前页只展示治理 readiness，不提供生产写入、版本升级或 contract 变更。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        governanceRow(
                          icon: Icons.verified_outlined,
                          title: '发布基线',
                          description:
                              '当前正式发布基线保持 0.04.09 / 40900；5.4 不改 release chain。',
                          status: '只读',
                          checks: const [
                            '版本中心截图必须来自当前安装包。',
                            'version check 结果需要和宿主版本链分开记录。',
                            '如不发版，不修改 build.gradle、changelog 或 app_update 配置。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.storage_outlined,
                          title: '云端数据库',
                          description: '本轮只建立只读核验入口与 runbook，不在前端执行生产库写入。',
                          status: '待核验',
                          checks: const [
                            '确认环境、只读身份和检查目标。',
                            '只记录聚合状态，不导出私密用户数据。',
                            '写库、迁移、恢复必须另走用户确认。',
                          ],
                          runbook:
                              'docs/runbooks/CLOUD_READONLY_DB_ACCESS_AND_AUDIT.md',
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.sensors_outlined,
                          title: '观测入口',
                          description:
                              'health / version / notification / media / queue / RTC 统一进入证据索引核验。',
                          status: '索引化',
                          checks: const [
                            '每个观测项必须说明来源：UI、命令、日志或只读云端。',
                            '没有当前证据时保留为待核验。',
                            '截图、XML、日志摘要必须和 evidence index 对应。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 45),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.monitor_heart_outlined,
                          '观测与回归核验入口',
                          '把 5.4 需要核验的服务面集中到一个只读清单，避免散落在截图和口头记录里。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        governanceRow(
                          icon: Icons.favorite_border,
                          title: 'Health / Version',
                          description: 'health 与版本中心必须用当前包和当前环境证据确认，不复用旧截图。',
                          status: '待采证',
                          checks: const [
                            '采集当前安装包的版本中心截图与 XML。',
                            '如调用 health/version endpoint，记录环境和时间。',
                            '网络失败不能写成业务成功。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.notifications_none,
                          title: 'Notification',
                          description:
                              '只核验通知中心可达、payload 跳转方向和未读处理，不改通知 contract。',
                          status: '只读',
                          checks: const [
                            '记录 message/status/rtc/system payload 类型。',
                            '核验 conversation_id / peer_user_id 等跳转字段方向。',
                            '未知跳转目标只能保留低噪声处理。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.perm_media_outlined,
                          title: 'Media',
                          description:
                              '只记录图片 / 视频链路状态和公开 URL 可读性，不调整 OSS 或播放器主链。',
                          status: '待核验',
                          checks: const [
                            '检查 public_url 是否可读且不是 localhost。',
                            '记录 media_assets / processing job 状态来源。',
                            '不重写上传、转码、播放器或附件语义。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.call_outlined,
                          title: 'RTC / LiveKit',
                          description:
                              '只核验权限页、结果页和连接证据；不改 RTC API contract 或房间状态机。',
                          status: '边界保护',
                          checks: const [
                            '核验权限页、通话结果页和 1v1 语音主链可达性。',
                            '如涉及 join-info / heartbeat，先写证据或 blocker。',
                            '不扩多人、直播、视频房间或 LiveKit contract。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.queue_outlined,
                          title: 'Queue / Logs',
                          description: '队列与日志只作为观测证据入口；没有当前日志证据时不得写成已通过。',
                          status: '待接入',
                          checks: const [
                            '记录 worker / queue / Laravel 日志来源。',
                            '只摘录错误摘要，不复制敏感 payload。',
                            '日志和用户面不一致时进入 blocker report。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 55),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.science_outlined,
                          '测试账号治理',
                          '用最小指标区分真实用户、测试用户与合成用户，避免测试数据污染运营口径。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppChoiceChip(
                              label: '测试账号 $testUsers',
                              selected: false,
                            ),
                            AppChoiceChip(
                              label: '合成用户 $synthetic',
                              selected: false,
                            ),
                            AppChoiceChip(
                              label: '排除指标 $excludedFromMetrics',
                              selected: false,
                            ),
                            AppChoiceChip(
                              label: '广场可见合成 $squareVisibleSynthetic',
                              selected: false,
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.sm),
                        Text(
                          '账号清理、可见性调整和指标排除仍需通过后续 runbook 或后台最小确认流执行。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 60),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.fact_check_outlined,
                          'Smoke / Regression Matrix',
                          '把小样本测试前必须回归的用户面路径集中到只读矩阵，避免依赖临时记忆。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        governanceRow(
                          icon: Icons.login_outlined,
                          title: 'Login / Profile Truth',
                          description:
                              '核验 SmokeUser / test1 可登录、资料真值链可读、Edit Profile 入口可达。',
                          status: '待采证',
                          checks: const [
                            '不在仓库记录密码或 token。',
                            'profile truth 只能以服务端为准，前端缓存只能兜底。',
                            '截图证据需要覆盖 Me / Edit Profile / truth 提示。',
                          ],
                          runbook:
                              'docs/runbooks/SYNTHETIC_ACCOUNT_GOVERNANCE.md',
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.travel_explore_outlined,
                          title: 'Discover / Match / Status',
                          description: '只核验 5.0-5.3 产品主链仍可达，不重做推荐算法或状态流策略。',
                          status: '回归',
                          checks: const [
                            'Discover 搜索、推荐理由和长按 action sheet 仍可见。',
                            'Match 解释与聊天入口仍可达。',
                            'Status Square / Author route 不被治理入口影响。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.forum_outlined,
                          title: 'Messages / Chat / Notification',
                          description:
                              '核验消息列表、聊天页、通知中心回流和 payload 方向，不改消息或通知 contract。',
                          status: '回归',
                          checks: const [
                            'Messages 和 Chat room 仍可达。',
                            'Notification Center 的打开 / 稍后处理 / 标记已读仍可见。',
                            'conversation_id / peer_user_id 真实方向仍保留为核验项。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                        governanceRow(
                          icon: Icons.mic_none_outlined,
                          title: 'Media / RTC / Version Center',
                          description:
                              '核验媒体附件、RTC 权限/结果页和版本中心；不升级到直播、多方 RTC 或发版链变更。',
                          status: '保护面',
                          checks: const [
                            '图片 / 视频消息入口和 public_url 证据分开记录。',
                            'RTC 只核验 1v1 语音保护面。',
                            'Version Center 必须继续显示 0.04.09 / 40900。',
                          ],
                          evidence:
                              'docs/version_plans/5.4_OBSERVABILITY_EVIDENCE_INDEX.md',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 65),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.backup_table_outlined,
                          '备份 / 恢复 / 迁移 readiness',
                          '这里是测试运营前的安全闸门提示，不在 Flutter 端执行恢复、迁移或生产库写入。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        governanceRow(
                          icon: Icons.cloud_done_outlined,
                          title: '备份存在性',
                          description: '只记录备份时间、环境和证据来源；不把备份文件或密钥放进仓库。',
                          status: 'runbook',
                          checks: const [
                            '确认环境、备份时间戳和备份责任人。',
                            '不复制备份文件、密钥或连接串进仓库。',
                            '无法确认备份时不得继续声明恢复 readiness。',
                          ],
                          runbook:
                              'docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md',
                        ),
                        governanceRow(
                          icon: Icons.restore_outlined,
                          title: '恢复演练',
                          description: '未在非生产环境演练前，不把 restore readiness 写成通过。',
                          status: '待确认',
                          checks: const [
                            '确认是否在非生产环境演练过。',
                            '生产恢复必须先有用户明确确认和新备份。',
                            '不得用 repo 级回滚替代数据恢复流程。',
                          ],
                          runbook:
                              'docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md',
                        ),
                        governanceRow(
                          icon: Icons.schema_outlined,
                          title: '迁移状态',
                          description:
                              '只读核验 migration level；5.4 不从前端或 Codex 直接执行迁移。',
                          status: '只读',
                          checks: const [
                            '只读记录 Laravel migration status 或部署日志来源。',
                            'pending migration 只能记录，不能由 Flutter 页面执行。',
                            'schema 不一致时先 blocker report。',
                          ],
                          runbook:
                              'docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md',
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
                        sectionTitle(
                          Icons.menu_book_outlined,
                          '5.4 Runbook Library',
                          '把测试运营准备需要反复使用的三份 runbook 集中到治理页，便于后续采证和交接。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        governanceRow(
                          icon: Icons.storage_rounded,
                          title: 'Cloud Read-only DB Audit',
                          description: '用于云端数据库只读检查、环境确认、审计记录和禁止写库边界。',
                          status: 'runbook',
                          checks: const [
                            '先确认环境和只读身份。',
                            '只记录聚合结果和审计摘要。',
                            '任何写库需求必须升级为用户确认或 blocker。',
                          ],
                          runbook:
                              'docs/runbooks/CLOUD_READONLY_DB_ACCESS_AND_AUDIT.md',
                        ),
                        governanceRow(
                          icon: Icons.settings_backup_restore_outlined,
                          title: 'Backup / Restore / Migration',
                          description: '用于备份存在性、恢复演练和 migration level 的测试前核验。',
                          status: 'runbook',
                          checks: const [
                            '确认备份时间戳和恢复演练状态。',
                            '生产恢复必须先有新备份和明确批准。',
                            'migration 只读核验，不从 Flutter 触发。',
                          ],
                          runbook:
                              'docs/runbooks/BACKUP_RESTORE_AND_MIGRATION_CHECK.md',
                        ),
                        governanceRow(
                          icon: Icons.group_work_outlined,
                          title: 'Synthetic Account Governance',
                          description:
                              '用于 smoke / synthetic / metric-excluded 账号的用途、隔离和恢复说明。',
                          status: 'runbook',
                          checks: const [
                            '不把密码、token 或私密身份信息写入仓库。',
                            'synthetic 账号不得污染真实推荐和运营指标。',
                            '测试账号缺数据时按最小范围恢复。',
                          ],
                          runbook:
                              'docs/runbooks/SYNTHETIC_ACCOUNT_GOVERNANCE.md',
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: t.spacing.md),
                SectionReveal(
                  delay: const Duration(milliseconds: 40),
                  child: AppCard(
                    padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        sectionTitle(
                          Icons.admin_panel_settings_outlined,
                          '治理入口',
                          '从这里进入举报处理、认证审核和用户列表。',
                        ),
                        SizedBox(height: t.spacing.sm),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppChoiceChip(
                              label: '运营后台',
                              selected: false,
                              onTap: () =>
                                  context.push(AppRouteNames.adminModeration),
                            ),
                            AppChoiceChip(
                              label: '认证审核',
                              selected: false,
                              onTap: () =>
                                  context.push(AppRouteNames.adminVerification),
                            ),
                            AppChoiceChip(
                              label: '用户列表',
                              selected: false,
                              onTap: () =>
                                  context.push(AppRouteNames.adminUsers),
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
                            Icon(
                              Icons.report_outlined,
                              size: 18,
                              color: t.brandPrimary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '最新举报',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: t.textPrimary,
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '保留最小概览，避免运营主页继续膨胀。',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: t.textSecondary, height: 1.45),
                        ),
                        SizedBox(height: t.spacing.sm),
                        if (state.reports.isEmpty)
                          Text(
                            '暂无举报。',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: t.textSecondary),
                          )
                        else
                          ...state.reports
                              .take(4)
                              .map(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.category.isEmpty ? '未分类' : item.category} · ${item.status}',
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
                                          '${item.reporter.name.isNotEmpty ? item.reporter.name : '匿名'} → ${item.targetUser.name.isNotEmpty ? item.targetUser.name : '目标用户'}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textSecondary,
                                              ),
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
