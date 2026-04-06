import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';

class AstroChartSettingsPage extends ConsumerWidget {
  const AstroChartSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final prefs = ref.watch(astroChartSettingsProvider);
    final notifier = ref.read(astroChartSettingsProvider.notifier);

    return AppScaffold(
      appBar: const AppTopBar(
        title: '盘面设置',
        mode: AppTopBarMode.backTitle,
      ),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '盘面设置',
              subtitle: '仅影响本地展示，不影响命盘真值',
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 30),
            child: AppInfoSectionCard(
              title: '设置说明',
              subtitle: '星盘页可按本地偏好控制摘要密度与技术参数展示',
              leadingIcon: Icons.tune_rounded,
              child: Text(
                '这些开关只控制详情页渲染，不修改后端画像、星盘、八字或紫微的 canonical 真值。建议在首次验收时先保持默认开启，确认信息完整后再逐项收紧。',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: SettingsGroup(
              title: '显示项',
              children: [
                SettingsItemTile(
                  title: '行星摘要',
                  subtitle: '显示行星、星座和落座列表',
                  icon: Icons.public_rounded,
                  trailing: AppSwitch(
                    value: prefs.showPlanetSummary,
                    onChanged: notifier.setShowPlanetSummary,
                  ),
                  onTap: () => notifier.setShowPlanetSummary(!prefs.showPlanetSummary),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '宫位摘要',
                  subtitle: '显示十二宫列表与位置',
                  icon: Icons.view_column_rounded,
                  trailing: AppSwitch(
                    value: prefs.showHouseSummary,
                    onChanged: notifier.setShowHouseSummary,
                  ),
                  onTap: () => notifier.setShowHouseSummary(!prefs.showHouseSummary),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '相位摘要',
                  subtitle: '显示主要相位关系',
                  icon: Icons.share_outlined,
                  trailing: AppSwitch(
                    value: prefs.showAspectSummary,
                    onChanged: notifier.setShowAspectSummary,
                  ),
                  onTap: () => notifier.setShowAspectSummary(!prefs.showAspectSummary),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '技术参数',
                  subtitle: '显示真太阳时、位置修正与引擎信息',
                  icon: Icons.fact_check_outlined,
                  trailing: AppSwitch(
                    value: prefs.showTechnicalParameters,
                    onChanged: notifier.setShowTechnicalParameters,
                  ),
                  onTap: () => notifier.setShowTechnicalParameters(!prefs.showTechnicalParameters),
                ),
              ],
            ),
          ),
          SectionReveal(
            delay: const Duration(milliseconds: 90),
            child: SettingsGroup(
              title: '视觉密度',
              children: [
                SettingsItemTile(
                  title: '紧凑模式',
                  subtitle: '减小摘要与卡片间距，减少视觉占位',
                  icon: Icons.compress_rounded,
                  trailing: AppSwitch(
                    value: prefs.compactDensity,
                    onChanged: notifier.setCompactDensity,
                  ),
                  onTap: () => notifier.setCompactDensity(!prefs.compactDensity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
