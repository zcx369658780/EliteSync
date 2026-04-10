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
      appBar: const AppTopBar(title: '盘面设置', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(title: '盘面设置', subtitle: '仅影响本地展示，不影响命盘真值'),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 30),
            child: AppInfoSectionCard(
              title: '设置说明',
              subtitle: '星盘页可按本地偏好控制摘要密度与盘面元素',
              leadingIcon: Icons.tune_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这些开关只控制本地展示，不修改后端画像、星盘、八字或紫微的 canonical 真值。你可以用上方的摘要开关控制下方信息，也可以用盘面元素开关直接隐藏图上的标签、相位线和辅助线。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => notifier.resetToDefaults(),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('恢复默认'),
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '恢复默认会把摘要显示和盘面元素重新设为推荐值，便于验收时回到标准构图。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 45),
            child: SettingsGroup(
              title: '快速预设',
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.md,
                    vertical: t.spacing.sm,
                  ),
                  child: Wrap(
                    spacing: t.spacing.sm,
                    runSpacing: t.spacing.sm,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () =>
                            notifier.applyPreset(AstroChartDisplayPreset.full),
                        icon: const Icon(Icons.visibility_rounded),
                        label: const Text('完整版'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => notifier.applyPreset(
                          AstroChartDisplayPreset.balanced,
                        ),
                        icon: const Icon(Icons.tune_rounded),
                        label: const Text('平衡版'),
                      ),
                      FilledButton.tonalIcon(
                        onPressed: () => notifier.applyPreset(
                          AstroChartDisplayPreset.minimal,
                        ),
                        icon: const Icon(Icons.minimize_rounded),
                        label: const Text('极简版'),
                      ),
                    ],
                  ),
                ),
              ],
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
                  onTap: () =>
                      notifier.setShowPlanetSummary(!prefs.showPlanetSummary),
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
                  onTap: () =>
                      notifier.setShowHouseSummary(!prefs.showHouseSummary),
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
                  onTap: () =>
                      notifier.setShowAspectSummary(!prefs.showAspectSummary),
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
                  onTap: () => notifier.setShowTechnicalParameters(
                    !prefs.showTechnicalParameters,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 75),
            child: SettingsGroup(
              title: '盘面元素',
              children: [
                SettingsItemTile(
                  title: '星座分区线',
                  subtitle: '隐藏外圈星座分割线',
                  icon: Icons.grid_3x3_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartSignGridLines,
                    onChanged: notifier.setShowChartSignGridLines,
                  ),
                  onTap: () => notifier.setShowChartSignGridLines(
                    !prefs.showChartSignGridLines,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '星座文字',
                  subtitle: '隐藏外圈星座名称',
                  icon: Icons.language_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartSignLabels,
                    onChanged: notifier.setShowChartSignLabels,
                  ),
                  onTap: () => notifier.setShowChartSignLabels(
                    !prefs.showChartSignLabels,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '宫位分割线',
                  subtitle: '隐藏十二宫分割线',
                  icon: Icons.view_week_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartHouseLines,
                    onChanged: notifier.setShowChartHouseLines,
                  ),
                  onTap: () => notifier.setShowChartHouseLines(
                    !prefs.showChartHouseLines,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '宫位编号',
                  subtitle: '隐藏十二宫数字标记',
                  icon: Icons.format_list_numbered_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartHouseNumbers,
                    onChanged: notifier.setShowChartHouseNumbers,
                  ),
                  onTap: () => notifier.setShowChartHouseNumbers(
                    !prefs.showChartHouseNumbers,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '相位连线',
                  subtitle: '隐藏盘中的相位关系连线',
                  icon: Icons.share_location_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartAspectLines,
                    onChanged: notifier.setShowChartAspectLines,
                  ),
                  onTap: () => notifier.setShowChartAspectLines(
                    !prefs.showChartAspectLines,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '行星引导线',
                  subtitle: '隐藏行星到文字的连接线',
                  icon: Icons.linear_scale_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartPlanetConnectors,
                    onChanged: notifier.setShowChartPlanetConnectors,
                  ),
                  onTap: () => notifier.setShowChartPlanetConnectors(
                    !prefs.showChartPlanetConnectors,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '行星点位',
                  subtitle: '隐藏行星圆点，仅保留其他元素',
                  icon: Icons.circle_outlined,
                  trailing: AppSwitch(
                    value: prefs.showChartPlanetMarkers,
                    onChanged: notifier.setShowChartPlanetMarkers,
                  ),
                  onTap: () => notifier.setShowChartPlanetMarkers(
                    !prefs.showChartPlanetMarkers,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '行星文字',
                  subtitle: '隐藏行星名称标签',
                  icon: Icons.text_fields_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartPlanetLabels,
                    onChanged: notifier.setShowChartPlanetLabels,
                  ),
                  onTap: () => notifier.setShowChartPlanetLabels(
                    !prefs.showChartPlanetLabels,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '盘心标题',
                  subtitle: '隐藏盘心姓名',
                  icon: Icons.center_focus_strong_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartCenterTitle,
                    onChanged: notifier.setShowChartCenterTitle,
                  ),
                  onTap: () => notifier.setShowChartCenterTitle(
                    !prefs.showChartCenterTitle,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '盘心时间',
                  subtitle: '隐藏盘心出生时间',
                  icon: Icons.schedule_rounded,
                  trailing: AppSwitch(
                    value: prefs.showChartCenterSubtitle,
                    onChanged: notifier.setShowChartCenterSubtitle,
                  ),
                  onTap: () => notifier.setShowChartCenterSubtitle(
                    !prefs.showChartCenterSubtitle,
                  ),
                ),
                Divider(height: 1, color: t.overlay.withValues(alpha: 0.35)),
                SettingsItemTile(
                  title: '盘心地点',
                  subtitle: '隐藏盘心出生地点',
                  icon: Icons.place_outlined,
                  trailing: AppSwitch(
                    value: prefs.showChartCenterPlace,
                    onChanged: notifier.setShowChartCenterPlace,
                  ),
                  onTap: () => notifier.setShowChartCenterPlace(
                    !prefs.showChartCenterPlace,
                  ),
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
                  onTap: () =>
                      notifier.setCompactDensity(!prefs.compactDensity),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
