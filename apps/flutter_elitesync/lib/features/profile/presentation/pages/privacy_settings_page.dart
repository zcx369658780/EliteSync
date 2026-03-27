import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/profile/presentation/widgets/settings_group.dart';

class PrivacySettingsPage extends StatefulWidget {
  const PrivacySettingsPage({super.key});

  @override
  State<PrivacySettingsPage> createState() => _PrivacySettingsPageState();
}

class _PrivacySettingsPageState extends State<PrivacySettingsPage> {
  bool profileVisible = true;
  bool showCity = true;

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
            child: SettingsGroup(
              title: '个人资料',
              children: [
                SettingsItemTile(
                  title: '公开个人资料',
                  subtitle: '关闭后仅匹配对象可见你的资料摘要',
                  icon: Icons.visibility_outlined,
                  trailing: Switch(
                    value: profileVisible,
                    onChanged: (v) => setState(() => profileVisible = v),
                  ),
                ),
                const Divider(height: 1),
                SettingsItemTile(
                  title: '显示城市',
                  subtitle: '用于同城匹配和线下活动组织',
                  icon: Icons.location_city_outlined,
                  trailing: Switch(
                    value: showCity,
                    onChanged: (v) => setState(() => showCity = v),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
