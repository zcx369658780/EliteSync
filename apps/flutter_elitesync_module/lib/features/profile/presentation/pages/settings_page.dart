import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/providers/auth_guard_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/performance_mode_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushEnabled = true;
  bool _pushLoaded = false;
  bool _performanceLiteMode = false;

  @override
  void initState() {
    super.initState();
    _loadPushSetting();
  }

  Future<void> _loadPushSetting() async {
    final local = ref.read(localStorageProvider);
    final value = await local.getBool(CacheKeys.pushNotificationEnabled);
    final perfLite = await local.getBool(CacheKeys.performanceLiteMode);
    if (!mounted) return;
    setState(() {
      _pushEnabled = value ?? true;
      _performanceLiteMode = perfLite ?? false;
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(value ? '已开启性能模式（动画降低）' : '已关闭性能模式'),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    await ref.read(logoutUseCaseProvider).call();
    await ref.read(sessionProvider.notifier).setUnauthenticated();
    if (context.mounted) {
      context.go(AppRouteNames.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
          0,
          t.spacing.sm,
          0,
          t.spacing.xl,
        ),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '设置中心',
              subtitle: '管理账号、隐私与通知偏好',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: SettingsGroup(
              title: '账号与安全',
              children: [
                SettingsItemTile(
                  title: '隐私设置',
                  subtitle: '控制资料可见范围与城市展示',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => context.push(AppRouteNames.privacySettings),
                ),
                const Divider(height: 1),
                SettingsItemTile(
                  title: '修改密码',
                  subtitle: '通过后端接口更新登录密码',
                  icon: Icons.lock_outline_rounded,
                  onTap: () => context.push(AppRouteNames.changePassword),
                ),
                const Divider(height: 1),
                SettingsItemTile(
                  title: '退出登录',
                  subtitle: '安全退出当前账号',
                  icon: Icons.logout_rounded,
                  trailing: Icon(Icons.logout_rounded, color: t.error),
                  onTap: () => _handleLogout(context, ref),
                ),
              ],
            ),
          ),
          SectionReveal(
            delay: const Duration(milliseconds: 110),
            child: _pushLoaded
                ? SettingsGroup(
              title: '消息与提醒',
              children: [
                SettingsItemTile(
                  title: '推送提醒',
                  subtitle: '匹配揭晓、消息提醒与活动通知',
                  icon: Icons.notifications_outlined,
                  trailing: Switch.adaptive(
                    value: _pushEnabled,
                    onChanged: _togglePush,
                  ),
                  onTap: () => _togglePush(!_pushEnabled),
                ),
                const Divider(height: 1),
                SettingsItemTile(
                  title: '性能模式',
                  subtitle: '降低动画与背景渲染，改善卡顿',
                  icon: Icons.bolt_outlined,
                  trailing: Switch.adaptive(
                    value: _performanceLiteMode,
                    onChanged: _togglePerformanceLiteMode,
                  ),
                  onTap: () => _togglePerformanceLiteMode(!_performanceLiteMode),
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
          SectionReveal(
            delay: Duration(milliseconds: 160),
            child: SettingsGroup(
              title: '关于',
              children: [
                SettingsItemTile(
                  title: '版本与更新',
                  subtitle: '查看版本号与更新历史',
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
