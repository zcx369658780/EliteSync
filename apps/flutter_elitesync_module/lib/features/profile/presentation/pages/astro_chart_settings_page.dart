import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/controls/app_switch.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_calibration_report.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_parity_report.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/settings_group.dart';

class AstroChartSettingsPage extends ConsumerWidget {
  const AstroChartSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    final prefs = ref.watch(astroChartSettingsProvider);
    final notifier = ref.read(astroChartSettingsProvider.notifier);
    final routePrefs = ref.watch(astroChartRouteProvider);
    final routeNotifier = ref.read(astroChartRouteProvider.notifier);
    final workbenchPrefs = ref.watch(astroChartWorkbenchProvider);
    final workbenchNotifier = ref.read(astroChartWorkbenchProvider.notifier);

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
              subtitle: '星盘页可按本地偏好控制显示摘要密度与盘面元素',
              leadingIcon: Icons.tune_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这些开关只控制本地展示，不修改后端画像、星盘、八字或紫微的 canonical 真值。你可以用上方的摘要显示开关控制下方信息，也可以用盘面元素开关直接隐藏图上的标签、相位线和辅助线。',
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
                    '恢复默认会把显示摘要和盘面元素重新设为推荐值，便于验收时回到标准构图。',
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
            delay: const Duration(milliseconds: 38),
            child: AppInfoSectionCard(
              title: '路线模板',
              subtitle: '标准 / 古典 / 现代路线，切换后同步推荐工作台参数',
              leadingIcon: Icons.alt_route_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '路线模板只表示当前盘面采用的展示与解释上下文，不会改写服务端真值。选择路线后，会同步应用该路线的推荐工作台参数，便于你快速对比标准、古典和现代三种视图。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      _RouteChoiceChip(
                        label: '标准路线',
                        selected:
                            routePrefs.routeMode ==
                            AstroChartRouteMode.standard,
                        onTap: () => _applyRouteMode(
                          routeNotifier,
                          workbenchNotifier,
                          AstroChartRouteMode.standard,
                        ),
                      ),
                      _RouteChoiceChip(
                        label: '古典路线',
                        selected:
                            routePrefs.routeMode ==
                            AstroChartRouteMode.classical,
                        onTap: () => _applyRouteMode(
                          routeNotifier,
                          workbenchNotifier,
                          AstroChartRouteMode.classical,
                        ),
                      ),
                      _RouteChoiceChip(
                        label: '现代路线',
                        selected:
                            routePrefs.routeMode == AstroChartRouteMode.modern,
                        onTap: () => _applyRouteMode(
                          routeNotifier,
                          workbenchNotifier,
                          AstroChartRouteMode.modern,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AstroPill(
                        label: '当前路线：${_routeModeLabel(routePrefs.routeMode)}',
                      ),
                      AstroPill(
                        label:
                            '上下文：${_routeModeDescription(routePrefs.routeMode)}',
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '切换路线后，请先看本命盘详情页再回到工作台微调黄道制、宫位制、相位密度与容许度。',
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
            delay: const Duration(milliseconds: 52),
            child: AppInfoSectionCard(
              title: '工作台参数',
              subtitle: '参数面板 MVP：先做口径分层，再逐步接入引擎升级',
              leadingIcon: Icons.tune_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '黄道制和宫位制先作为工作台口径保留；相位密度、容许度和点位范围会直接影响本地盘面的可见元素。当前工作台会跟随所选路线模板切换到推荐默认值，但所有参数仍然不改写服务端 canonical 真值。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  _WorkbenchRow(
                    title: '黄道制',
                    chips: [
                      _WorkbenchChip(
                        label: '回归黄道',
                        selected:
                            workbenchPrefs.zodiacMode ==
                            AstroZodiacMode.tropical,
                        onTap: () => workbenchNotifier.setZodiacMode(
                          AstroZodiacMode.tropical,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '恒星黄道',
                        selected:
                            workbenchPrefs.zodiacMode ==
                            AstroZodiacMode.sidereal,
                        onTap: () => workbenchNotifier.setZodiacMode(
                          AstroZodiacMode.sidereal,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  _WorkbenchRow(
                    title: '宫位制',
                    chips: [
                      _WorkbenchChip(
                        label: 'Whole',
                        selected:
                            workbenchPrefs.houseSystem ==
                            AstroHouseSystem.whole,
                        onTap: () => workbenchNotifier.setHouseSystem(
                          AstroHouseSystem.whole,
                        ),
                      ),
                      _WorkbenchChip(
                        label: 'Placidus',
                        selected:
                            workbenchPrefs.houseSystem ==
                            AstroHouseSystem.placidus,
                        onTap: () => workbenchNotifier.setHouseSystem(
                          AstroHouseSystem.placidus,
                        ),
                      ),
                      _WorkbenchChip(
                        label: 'Alcabitius',
                        selected:
                            workbenchPrefs.houseSystem ==
                            AstroHouseSystem.alcabitius,
                        onTap: () => workbenchNotifier.setHouseSystem(
                          AstroHouseSystem.alcabitius,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  _WorkbenchRow(
                    title: '相位密度',
                    chips: [
                      _WorkbenchChip(
                        label: '主相位',
                        selected:
                            workbenchPrefs.aspectMode == AstroAspectMode.major,
                        onTap: () => workbenchNotifier.setAspectMode(
                          AstroAspectMode.major,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '标准',
                        selected:
                            workbenchPrefs.aspectMode ==
                            AstroAspectMode.standard,
                        onTap: () => workbenchNotifier.setAspectMode(
                          AstroAspectMode.standard,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '扩展',
                        selected:
                            workbenchPrefs.aspectMode ==
                            AstroAspectMode.extended,
                        onTap: () => workbenchNotifier.setAspectMode(
                          AstroAspectMode.extended,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  _WorkbenchRow(
                    title: '容许度',
                    chips: [
                      _WorkbenchChip(
                        label: '紧凑',
                        selected:
                            workbenchPrefs.orbPreset == AstroOrbPreset.tight,
                        onTap: () => workbenchNotifier.setOrbPreset(
                          AstroOrbPreset.tight,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '标准',
                        selected:
                            workbenchPrefs.orbPreset == AstroOrbPreset.standard,
                        onTap: () => workbenchNotifier.setOrbPreset(
                          AstroOrbPreset.standard,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '宽松',
                        selected:
                            workbenchPrefs.orbPreset == AstroOrbPreset.wide,
                        onTap: () =>
                            workbenchNotifier.setOrbPreset(AstroOrbPreset.wide),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  _WorkbenchRow(
                    title: '点位范围',
                    chips: [
                      _WorkbenchChip(
                        label: '核心',
                        selected:
                            workbenchPrefs.pointMode == AstroPointMode.core,
                        onTap: () =>
                            workbenchNotifier.setPointMode(AstroPointMode.core),
                      ),
                      _WorkbenchChip(
                        label: '扩展',
                        selected:
                            workbenchPrefs.pointMode == AstroPointMode.extended,
                        onTap: () => workbenchNotifier.setPointMode(
                          AstroPointMode.extended,
                        ),
                      ),
                      _WorkbenchChip(
                        label: '全量',
                        selected:
                            workbenchPrefs.pointMode == AstroPointMode.full,
                        onTap: () =>
                            workbenchNotifier.setPointMode(AstroPointMode.full),
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => workbenchNotifier.resetToDefaults(),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text('工作台重置'),
                    ),
                  ),
                  SizedBox(height: t.spacing.xs),
                  Text(
                    '当前会影响盘面的参数：相位密度、容许度、点位范围。黄道制与宫位制先作为工作台口径保留，待后续引擎升级版本接入。',
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
            delay: const Duration(milliseconds: 58),
            child: AppInfoSectionCard(
              title: '参数解读',
              subtitle: '帮助理解当前工作台配置对盘面的影响',
              leadingIcon: Icons.menu_book_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '这是一层解释，不是新的算法入口。当前会直接影响盘面的只有相位密度、容许度和点位范围；黄道制与宫位制先作为工作台口径保留，等待后续引擎升级版本接入。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                  SizedBox(height: t.spacing.sm),
                  Wrap(
                    spacing: t.spacing.xs,
                    runSpacing: t.spacing.xs,
                    children: [
                      AstroPill(
                        label:
                            '黄道：${_zodiacModeLabel(workbenchPrefs.zodiacMode)}',
                      ),
                      AstroPill(
                        label:
                            '宫位：${_houseSystemLabel(workbenchPrefs.houseSystem)}',
                      ),
                      AstroPill(
                        label:
                            '相位：${_aspectModeLabel(workbenchPrefs.aspectMode)}',
                      ),
                      AstroPill(
                        label:
                            '容许度：${_orbPresetLabel(workbenchPrefs.orbPreset)}',
                      ),
                      AstroPill(
                        label:
                            '点位：${_pointModeLabel(workbenchPrefs.pointMode)}',
                      ),
                    ],
                  ),
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '理解顺序建议：先看“路线模板”决定当前路由上下文，再看“点位范围”决定有哪些天体可见，然后看“相位密度”和“容许度”决定连线密度，最后把“黄道制 / 宫位制”当作后续引擎升级预留口径。',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 62),
            child: _ParameterLinkageCard(
              routePrefs: routePrefs,
              workbenchPrefs: workbenchPrefs,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 64),
            child: AstroRouteParityReportCard(
              currentRouteMode: routePrefs.routeMode,
              currentWorkbench: workbenchPrefs,
              compact: false,
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 66),
            child: AstroCalibrationReportCard(
              onOpenDetails: () =>
                  context.push(AppRouteNames.astroAdvancedPreviewDemo),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 60),
            child: SettingsGroup(
              title: '摘要显示',
              children: [
                SettingsItemTile(
                  title: '显示行星摘要',
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
                  title: '显示宫位摘要',
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
                  title: '显示相位摘要',
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
                  title: '显示技术参数',
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

String _zodiacModeLabel(AstroZodiacMode mode) {
  switch (mode) {
    case AstroZodiacMode.tropical:
      return '回归黄道';
    case AstroZodiacMode.sidereal:
      return '恒星黄道';
  }
}

String _houseSystemLabel(AstroHouseSystem mode) {
  switch (mode) {
    case AstroHouseSystem.whole:
      return 'Whole';
    case AstroHouseSystem.placidus:
      return 'Placidus';
    case AstroHouseSystem.alcabitius:
      return 'Alcabitius';
  }
}

String _aspectModeLabel(AstroAspectMode mode) {
  switch (mode) {
    case AstroAspectMode.major:
      return '主相位';
    case AstroAspectMode.standard:
      return '标准';
    case AstroAspectMode.extended:
      return '扩展';
  }
}

String _orbPresetLabel(AstroOrbPreset mode) {
  switch (mode) {
    case AstroOrbPreset.tight:
      return '紧凑';
    case AstroOrbPreset.standard:
      return '标准';
    case AstroOrbPreset.wide:
      return '宽松';
  }
}

String _pointModeLabel(AstroPointMode mode) {
  switch (mode) {
    case AstroPointMode.core:
      return '核心';
    case AstroPointMode.extended:
      return '扩展';
    case AstroPointMode.full:
      return '全量';
  }
}

class _WorkbenchRow extends StatelessWidget {
  const _WorkbenchRow({required this.title, required this.chips});

  final String title;
  final List<Widget> chips;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Wrap(spacing: t.spacing.xs, runSpacing: t.spacing.xs, children: chips),
      ],
    );
  }
}

class _WorkbenchChip extends StatelessWidget {
  const _WorkbenchChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChoiceChip(label: label, selected: selected, onTap: onTap);
  }
}

Future<void> _applyRouteMode(
  AstroChartRouteNotifier routeNotifier,
  AstroChartWorkbenchNotifier workbenchNotifier,
  AstroChartRouteMode routeMode,
) async {
  await routeNotifier.setRouteMode(routeMode);
  await workbenchNotifier.applyPreset(_workbenchPresetForRoute(routeMode));
}

AstroChartWorkbenchPreset _workbenchPresetForRoute(
  AstroChartRouteMode routeMode,
) {
  switch (routeMode) {
    case AstroChartRouteMode.standard:
      return AstroChartWorkbenchPreset.standard;
    case AstroChartRouteMode.classical:
      return AstroChartWorkbenchPreset.classical;
    case AstroChartRouteMode.modern:
      return AstroChartWorkbenchPreset.modern;
  }
}

String _routeModeLabel(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return '标准路线';
    case AstroChartRouteMode.classical:
      return '古典路线';
    case AstroChartRouteMode.modern:
      return '现代路线';
  }
}

String _routeModeDescription(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return 'tropical / whole / standard';
    case AstroChartRouteMode.classical:
      return 'sidereal / whole / tight';
    case AstroChartRouteMode.modern:
      return 'tropical / placidus / wide';
  }
}

class _ParameterLinkageCard extends StatelessWidget {
  const _ParameterLinkageCard({
    required this.routePrefs,
    required this.workbenchPrefs,
  });

  final AstroChartRoutePrefs routePrefs;
  final AstroChartWorkbenchPrefs workbenchPrefs;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppInfoSectionCard(
      title: '参数联动',
      subtitle: '从参数解读直达高级时法预览',
      leadingIcon: Icons.auto_awesome_motion_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '这里把路线模板、工作台参数和高级时法连成一条链：先看当前参数口径，再进入高级时法核对合盘、行运、返照与时法预览。该链路只做展示与关联说明，不回写 canonical truth。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: '路线：${_routeModeLabel(routePrefs.routeMode)}'),
              AstroPill(label: '黄道：${_zodiacModeLabel(workbenchPrefs.zodiacMode)}'),
              AstroPill(label: '宫位：${_houseSystemLabel(workbenchPrefs.houseSystem)}'),
              AstroPill(label: '相位：${_aspectModeLabel(workbenchPrefs.aspectMode)}'),
              AstroPill(label: '容许度：${_orbPresetLabel(workbenchPrefs.orbPreset)}'),
              AstroPill(label: '点位：${_pointModeLabel(workbenchPrefs.pointMode)}'),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () => context.push(AppRouteNames.astroAdvancedPreview),
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('打开高级时法'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteChoiceChip extends StatelessWidget {
  const _RouteChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppChoiceChip(label: label, selected: selected, onTap: onTap);
  }
}
