import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_mode.dart';
import 'package:flutter_elitesync/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync/shared/providers/theme_provider.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            child: PageTitleRail(title: '设置中心', subtitle: '管理账号、隐私与通知偏好'),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: SettingsGroup(
              title: '外观',
              children: [
                SettingsItemTile(
                  title: '夜间模式',
                  subtitle: '切换白天 / 黑夜配色',
                  icon: Icons.dark_mode_outlined,
                  trailing: Switch.adaptive(value: isDark, onChanged: setDark),
                  onTap: () => setDark(!isDark),
                ),
              ],
            ),
          ),
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
                const SettingsItemTile(
                  title: '修改密码',
                  subtitle: '通过后端接口更新登录密码',
                  icon: Icons.lock_outline_rounded,
                ),
              ],
            ),
          ),
          SectionReveal(
            delay: const Duration(milliseconds: 110),
            child: SettingsGroup(
              title: '消息与提醒',
              children: const [
                SettingsItemTile(
                  title: '推送提醒',
                  subtitle: '匹配揭晓、消息提醒与活动通知',
                  icon: Icons.notifications_outlined,
                ),
              ],
            ),
          ),
          const SectionReveal(
            delay: Duration(milliseconds: 160),
            child: SettingsGroup(
              title: '关于',
              children: [
                SettingsItemTile(
                  title: '版本与更新',
                  subtitle: '查看版本号与更新历史',
                  icon: Icons.system_update_alt_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
