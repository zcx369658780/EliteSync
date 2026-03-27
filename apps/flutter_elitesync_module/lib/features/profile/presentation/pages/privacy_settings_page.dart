import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends ConsumerState<PrivacySettingsPage> {
  bool profileVisible = true;
  bool showCity = true;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadLocalPrivacySettings();
  }

  Future<void> _loadLocalPrivacySettings() async {
    final local = ref.read(localStorageProvider);
    final profile = await local.getBool(CacheKeys.privacyProfileVisible);
    final city = await local.getBool(CacheKeys.privacyShowCity);
    if (!mounted) return;
    setState(() {
      profileVisible = profile ?? true;
      showCity = city ?? true;
      _loaded = true;
    });
  }

  Future<void> _setProfileVisible(bool value) async {
    final local = ref.read(localStorageProvider);
    await local.setBool(CacheKeys.privacyProfileVisible, value);
    if (!mounted) return;
    setState(() => profileVisible = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(value ? '已开启公开个人资料' : '已关闭公开个人资料'),
      ),
    );
  }

  Future<void> _setShowCity(bool value) async {
    final local = ref.read(localStorageProvider);
    await local.setBool(CacheKeys.privacyShowCity, value);
    if (!mounted) return;
    setState(() => showCity = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(value ? '已开启显示城市' : '已关闭显示城市'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '隐私设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.fromLTRB(0, t.spacing.sm, 0, t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '隐私与可见性',
              subtitle: '你可以随时调整对外展示范围',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: _loaded
                ? SettingsGroup(
              title: '个人资料',
              children: [
                SettingsItemTile(
                  title: '公开个人资料',
                  subtitle: '关闭后仅匹配对象可见你的资料摘要',
                  icon: Icons.visibility_outlined,
                  trailing: Switch.adaptive(
                    value: profileVisible,
                    onChanged: _setProfileVisible,
                  ),
                  onTap: () => _setProfileVisible(!profileVisible),
                ),
                const Divider(height: 1),
                SettingsItemTile(
                  title: '显示城市',
                  subtitle: '用于同城匹配和线下活动组织',
                  icon: Icons.location_city_outlined,
                  trailing: Switch.adaptive(
                    value: showCity,
                    onChanged: _setShowCity,
                  ),
                  onTap: () => _setShowCity(!showCity),
                ),
              ],
            )
                : const SettingsGroup(
                    title: '个人资料',
                    children: [
                      SettingsItemTile(
                        title: '隐私配置加载中',
                        subtitle: '请稍候...',
                        icon: Icons.hourglass_bottom_rounded,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
