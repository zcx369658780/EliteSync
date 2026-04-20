import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_confirm_dialog.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/theme_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushEnabled = true;
  bool _pushLoaded = false;
  bool _performanceLiteMode = false;
  String _contentRankerMode = 'auto';

  @override
  void initState() {
    super.initState();
    _loadPushSetting();
  }

  Future<void> _loadPushSetting() async {
    final local = ref.read(localStorageProvider);
    final value = await local.getBool(CacheKeys.pushNotificationEnabled);
    final perfLite = await local.getBool(CacheKeys.performanceLiteMode);
    final rankerMode =
        (await local.getString(
          CacheKeys.contentRankerMode,
        ))?.trim().toLowerCase() ??
        'auto';
    if (!mounted) return;
    setState(() {
      _pushEnabled = value ?? true;
      _performanceLiteMode = perfLite ?? false;
      _contentRankerMode =
          (rankerMode == 'weighted' ||
              rankerMode == 'legacy' ||
              rankerMode == 'auto')
          ? rankerMode
          : 'auto';
      _pushLoaded = true;
    });
  }

  Future<void> _togglePush(bool value) async {
    final local = ref.read(localStorageProvider);
    await local.setBool(CacheKeys.pushNotificationEnabled, value);
    if (!mounted) return;
    setState(() => _pushEnabled = value);
  }

  Future<void> _togglePerformanceLiteMode(bool value) async {
    final local = ref.read(localStorageProvider);
    await local.setBool(CacheKeys.performanceLiteMode, value);
    ref.invalidate(performanceLiteModeProvider);
    if (!mounted) return;
    setState(() => _performanceLiteMode = value);
    AppFeedback.showInfo(context, value ? '已开启性能模式（动画降低）' : '已关闭性能模式');
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await AppConfirmDialog.show(
      context,
      title: '退出登录',
      message: '退出后将返回登录页，需要重新输入账号和密码。',
      confirmLabel: '退出',
      cancelLabel: '取消',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(logoutUseCaseProvider).call();
    try {
      const channel = MethodChannel('elitesync/bootstrap');
      await channel.invokeMethod<void>('clearBootstrap');
    } catch (_) {}
    await ref.read(sessionProvider.notifier).setUnauthenticated();
    if (context.mounted) {
      context.go(AppRouteNames.login);
    }
  }

  Future<void> _clearContentCache() async {
    final local = ref.read(localStorageProvider);
    await local.remove(CacheKeys.homeFeedSnapshot);
    await local.remove(CacheKeys.discoverFeedSnapshot);
    await local.remove(CacheKeys.homeSearchHistory);
    await local.remove(CacheKeys.discoverSearchHistory);
    await local.remove(CacheKeys.messagesConversationSnapshot);
    if (!mounted) return;
    AppFeedback.showSuccess(context, '内容缓存已清理，下次进入将拉取最新内容');
  }

  Future<void> _resetContentPreference() async {
    final local = ref.read(localStorageProvider);
    await local.remove(CacheKeys.contentPreferredTag);
    await local.remove(CacheKeys.contentPreferredTagsMap);
    await local.remove(CacheKeys.homeFeedSnapshot);
    await local.remove(CacheKeys.discoverFeedSnapshot);
    if (!mounted) return;
    AppFeedback.showInfo(context, '推荐偏好已重置');
  }

  String get _rankerLabel {
    switch (_contentRankerMode) {
      case 'weighted':
        return '新排序';
      case 'legacy':
        return '旧排序';
      default:
        return '自动';
    }
  }

  Future<void> _cycleContentRankerMode() async {
    final next = switch (_contentRankerMode) {
      'auto' => 'weighted',
      'weighted' => 'legacy',
      _ => 'auto',
    };
    final local = ref.read(localStorageProvider);
    await local.setString(CacheKeys.contentRankerMode, next);
    await _clearContentCache();
    if (!mounted) return;
    setState(() => _contentRankerMode = next);
    AppFeedback.showInfo(context, '推荐策略已切换：$_rankerLabel');
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final themeMode = ref.watch(themeModeProvider);
    final isDark =
        themeMode == AppThemeMode.dark ||
        (themeMode == AppThemeMode.system &&
            Theme.of(context).brightness == Brightness.dark);
    Future<void> setDark(bool value) => ref
        .read(themeModeProvider.notifier)
        .setThemeMode(value ? AppThemeMode.dark : AppThemeMode.light);
    return AppScaffold(
      appBar: const AppTopBar(title: '设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(title: '设置中心', subtitle: '管理账号、显示、隐私、性能与版本偏好'),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: AppInfoSectionCard(
              title: '设置口径',
              subtitle: '本地偏好、账号设置与版本信息分区展示',
              leadingIcon: Icons.tune_rounded,
              child: Text(
                '夜间模式、盘面设置、性能模式与内容缓存属于本地偏好；隐私、密码与账号状态由服务端真值管理；版本中心只展示包体版本、服务状态和更新历史，不会改写任何业务真值。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 50),
            child: SettingsGroup(
              title: '显示与外观',
              children: [
                SettingsItemTile(
                  title: '夜间模式',
                  subtitle: '切换白天 / 黑夜配色',
                  icon: Icons.dark_mode_outlined,
                  trailing: Switch.adaptive(value: isDark, onChanged: setDark),
                  onTap: () => setDark(!isDark),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '盘面设置',
                  subtitle: '星盘元素、预设档位与恢复默认',
                  icon: Icons.auto_awesome_outlined,
                  onTap: () => context.push(AppRouteNames.astroChartSettings),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: SettingsGroup(
              title: '性能偏好',
              children: [
                SettingsItemTile(
                  title: '性能模式',
                  subtitle: '降低动画与背景渲染，改善卡顿',
                  icon: Icons.bolt_outlined,
                  trailing: AppSwitch(
                    value: _performanceLiteMode,
                    onChanged: _togglePerformanceLiteMode,
                  ),
                  onTap: () =>
                      _togglePerformanceLiteMode(!_performanceLiteMode),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: SettingsGroup(
              title: '资料与显示',
              children: [
                SettingsItemTile(
                  title: '隐私设置',
                  subtitle: '控制资料可见范围与城市展示',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push(AppRouteNames.privacySettings),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 80),
            child: SettingsGroup(
              title: '账号与安全',
              children: [
                SettingsItemTile(
                  title: '修改密码',
                  subtitle: '通过后端接口更新登录密码',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => context.push(AppRouteNames.changePassword),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '退出登录',
                  subtitle: '安全退出当前账号',
                  icon: Icons.logout_rounded,
                  trailing: Icon(Icons.logout_rounded, color: t.error),
                  variant: SettingsItemVariant.destructive,
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          ),
          SectionReveal(
            delay: const Duration(milliseconds: 130),
            child: _pushLoaded
                ? SettingsGroup(
                    title: '消息与提醒',
                    children: [
                      SettingsItemTile(
                        title: '推送提醒',
                        subtitle: '匹配揭晓、消息提醒与活动通知',
                        icon: Icons.notifications_outlined,
                        trailing: AppSwitch(
                          value: _pushEnabled,
                          onChanged: _togglePush,
                        ),
                        onTap: () => _togglePush(!_pushEnabled),
                      ),
                      Divider(
                        height: 1,
                        color: t.overlay.withValues(alpha: 0.35),
                      ),
                    ],
                  )
                : SettingsGroup(
                    title: '消息与提醒',
                    children: const [
                      SettingsItemTile(
                        title: '推送提醒',
                        subtitle: '加载中...',
                        icon: Icons.notifications_outlined,
                      ),
                    ],
                  ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 145),
            child: AppInfoSectionCard(
              title: 'Beta 运营准备',
              subtitle: '版本检查、健康检查与回归门禁单独管理',
              leadingIcon: Icons.verified_rounded,
              child: Text(
                '正式 Beta 前，建议先确认版本中心、服务健康、弱网首进与回滚检查均已通过。这里展示的版本状态与健康检查只属于可观测性，不会改写任何资料真值或星盘真值。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          if (ref.watch(appEnvProvider).isDev) ...[
            SizedBox(height: t.spacing.md),
            SectionReveal(
              delay: const Duration(milliseconds: 160),
              child: SettingsGroup(
                title: '开发者',
                children: [
                  SettingsItemTile(
                    title: '运营看板',
                    subtitle: '最小指标概览与治理入口',
                    icon: Icons.dashboard_outlined,
                    onTap: () => context.push(AppRouteNames.adminDashboard),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '运营后台',
                    subtitle: '举报处理与用户治理',
                    icon: Icons.admin_panel_settings_outlined,
                    onTap: () => context.push(AppRouteNames.adminModeration),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '认证审核',
                    subtitle: '人工审核队列与状态处理',
                    icon: Icons.verified_user_outlined,
                    onTap: () => context.push(AppRouteNames.adminVerification),
                  ),
                  Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                  SettingsItemTile(
                    title: '用户列表',
                    subtitle: '查看用户状态与治理记录',
                    icon: Icons.people_outline,
                    onTap: () => context.push(AppRouteNames.adminUsers),
                  ),
                ],
              ),
            ),
          ],
          SectionReveal(
            delay: const Duration(milliseconds: 170),
            child: SettingsGroup(
              title: '内容缓存',
              children: [
                SettingsItemTile(
                  title: '推荐排序策略',
                  subtitle: '当前：$_rankerLabel（点击切换 自动/新排序/旧排序）',
                  icon: Icons.tune_rounded,
                  onTap: _cycleContentRankerMode,
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '重置内容偏好',
                  subtitle: '清除点击形成的标签偏好并回到默认排序',
                  icon: Icons.restart_alt_rounded,
                  onTap: _resetContentPreference,
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '清空首页/发现缓存',
                  subtitle: '立即清除本地内容快照，重新拉取服务端数据',
                  icon: Icons.cleaning_services_outlined,
                  onTap: _clearContentCache,
                ),
              ],
            ),
          ),
          SectionReveal(
            delay: const Duration(milliseconds: 200),
            child: SettingsGroup(
              title: '版本中心',
              children: [
                SettingsItemTile(
                  title: '版本中心',
                  subtitle: '查看版本号、服务状态与更新历史',
                  icon: Icons.system_update_alt_rounded,
                  onTap: () => context.push(AppRouteNames.aboutUpdate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
