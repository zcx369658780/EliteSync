import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/design_system/components/feedback/app_feedback.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class PrivacySettingsPage extends ConsumerStatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  ConsumerState<PrivacySettingsPage> createState() =>
      _PrivacySettingsPageState();
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
    AppFeedback.showInfo(context, value ? '已开启公开个人资料' : '已关闭公开个人资料');
  }

  Future<void> _setShowCity(bool value) async {
    final local = ref.read(localStorageProvider);
    await local.setBool(CacheKeys.privacyShowCity, value);
    if (!mounted) return;
    setState(() => showCity = value);
    AppFeedback.showInfo(context, value ? '已开启显示城市' : '已关闭显示城市');
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
              subtitle: '你可以随时调整资料摘要、城市展示与公开范围',
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 40),
            child: AppInfoSectionCard(
              title: '隐私策略说明',
              subtitle: '默认优先保护敏感画像信息',
              leadingIcon: Icons.privacy_tip_outlined,
              child: Text(
                '出生地点、八字、星盘等敏感信息默认不对外公开。本页只调整资料摘要与城市展示等可见性偏好，不会改写服务端的画像真值；你随时可以返回这里重新调整。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 55),
            child: AppInfoSectionCard(
              title: '可见性边界',
              subtitle: '开关只影响前台展示，不影响后台计算',
              leadingIcon: Icons.visibility_outlined,
              child: Text(
                '公开个人资料只会影响资料摘要是否对外展示；显示城市只会影响同城相关展示。若你修改了出生时间、出生地点或经纬度，请到资料页保存，服务端会重新计算星盘与画像结果。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.45,
                ),
              ),
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
                        trailing: AppSwitch(
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
                        trailing: AppSwitch(
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
