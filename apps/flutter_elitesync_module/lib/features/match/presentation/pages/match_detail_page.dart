import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_glossary_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_module_insight_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_reason_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_weight_breakdown.dart';

class MatchDetailPage extends ConsumerStatefulWidget {
  const MatchDetailPage({super.key});

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  bool _expanded = false;

  static const Map<String, String> _termGlossary = {
    '八字': '基于出生时间推算的四柱信息，常用于观察长期相处节律与生活稳定性倾向。',
    '五行': '木火土金水的结构分布。这里主要看双方互补度和均衡度，不作为绝对结论。',
    '属相六合': '传统上协同度较高的属相组合，通常表示互动更容易形成配合感。',
    '属相三合': '传统分组中的协同关系，一般代表节奏较容易对齐，但强度略低于六合。',
    '相冲': '关系节奏容易对撞，常见于推进速度或表达方式不一致。',
    '相刑': '相处中较易出现内耗或僵持，需要更清晰的边界与沟通规则。',
    '相害': '误解成本相对更高，建议在关键决策前增加确认步骤。',
    '星座元素': '火土风水四元素倾向，用于判断互动过程是否顺滑。',
    '星盘': '结合太阳、月亮、上升等要素的过程层分析，更偏“怎么相处”而非“能否长期”。',
    '上升': '更偏外在表达与互动风格，常影响第一印象和沟通方式。',
    '日月互动': '双方太阳与月亮之间的互动信号，侧重情感回应与关系推进节奏。',
    '情绪节奏': '双方在情绪表达、接收与反馈速度上的匹配程度。',
    '长期稳定': '在长期关系中作息、决策、压力处理是否容易形成可持续配合。',
    '合盘': '将双方星盘信号组合后的过程层分析，重点看互动路径与磨合成本。',
  };

  String _reasonHeadline(int index) {
    switch (index) {
      case 0:
        return '为什么值得认识';
      case 1:
        return '相处舒适区';
      case 2:
        return '需要留意';
      default:
        return '开场建议';
    }
  }

  List<MapEntry<String, String>> _collectGlossary(
    Iterable<String> textLines, {
    Map<String, String> serverGlossary = const {},
  }) {
    final joined = textLines.join('\n');
    final merged = <String, String>{..._termGlossary, ...serverGlossary};
    final matched = <MapEntry<String, String>>[];
    for (final e in merged.entries) {
      if (joined.contains(e.key)) {
        matched.add(e);
      }
    }
    // Ensure server-provided glossary items are still visible even when keyword extraction misses.
    for (final e in serverGlossary.entries) {
      if (!matched.any((m) => m.key == e.key)) {
        matched.add(e);
      }
    }
    return matched;
  }

  ({String module, int score, String reason, String? risk, List<String> tags}) _parseInsightLine(String line) {
    final trimmed = line.trim();
    final mainParts = trimmed.split('：');
    final title = mainParts.isNotEmpty ? mainParts.first.trim() : '匹配项';
    final body = mainParts.length > 1 ? mainParts.sublist(1).join('：').trim() : '';

    final moduleMatch = RegExp(r'^(.+?)（(\d+)分）$').firstMatch(title);
    final module = moduleMatch?.group(1)?.trim() ?? title;
    final score = int.tryParse(moduleMatch?.group(2) ?? '') ?? 0;

    String reason = body;
    String? risk;
    List<String> tags = const [];

    final segments = body.split('；').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final cleanReason = <String>[];
    for (final s in segments) {
      if (s.startsWith('风险提示：')) {
        risk = s.replaceFirst('风险提示：', '').trim();
        continue;
      }
      if (s.startsWith('证据标签：')) {
        tags = s
            .replaceFirst('证据标签：', '')
            .split('、')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
        continue;
      }
      cleanReason.add(s);
    }
    if (cleanReason.isNotEmpty) {
      reason = cleanReason.join('；');
    }

    return (
      module: module,
      score: score,
      reason: reason.isEmpty ? '暂无说明' : reason,
      risk: risk,
      tags: tags,
    );
  }

  ({List<String> highlights, List<String> risks}) _groupReasons(List<String> reasons) {
    final highlights = <String>[];
    final risks = <String>[];
    for (final raw in reasons) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('需要留意') || line.contains('风险') || line.contains('张力')) {
        risks.add(line);
      } else {
        highlights.add(line);
      }
    }
    return (highlights: highlights, risks: risks);
  }

  Widget _reasonSectionCard(
    BuildContext context, {
    required String title,
    required List<String> items,
    required IconData icon,
    required Color color,
  }) {
    final t = context.appTokens;
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: t.spacing.sm),
      padding: EdgeInsets.all(t.spacing.cardPadding),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              SizedBox(width: t.spacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          ...items.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• $e',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.45,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(matchDetailProvider);
    final t = context.appTokens;

    return AppScaffold(
      appBar: AppTopBar(
        title: '匹配详情',
        mode: AppTopBarMode.backTitle,
        actions: [
          IconButton(
            tooltip: '刷新',
            onPressed: () => ref.invalidate(matchDetailProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: async.when(
        loading: () => const AppLoadingSkeleton(lines: 7),
        error: (e, _) => AppErrorState(title: '详情加载失败', description: e.toString()),
        data: (data) {
          final grouped = _groupReasons(data.reasons);
          final maxReasonCount = _expanded ? 99 : 3;
          final maxInsightCount = _expanded ? 99 : 3;
          final visibleHighlights = grouped.highlights.take(maxReasonCount).toList();
          final visibleRisks = grouped.risks.take(maxReasonCount).toList();
          final visibleInsights = data.moduleInsights.take(maxInsightCount).toList();
          final hasMoreReasons =
              grouped.highlights.length > visibleHighlights.length || grouped.risks.length > visibleRisks.length;
          final hasMoreInsights = data.moduleInsights.length > visibleInsights.length;
          final canExpand = hasMoreReasons || hasMoreInsights;
          final glossaryEntries = _collectGlossary([
            ...data.reasons,
            ...visibleInsights,
          ], serverGlossary: data.reasonGlossary);
          return ListView(
            padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
            children: [
            const SectionReveal(
              child: PageTitleRail(
                title: '匹配解释',
                subtitle: '先看关系解释，再看参数补充',
              ),
            ),
            SizedBox(height: t.spacing.md),
            if (grouped.highlights.isNotEmpty)
              SectionReveal(
                delay: const Duration(milliseconds: 60),
                child: _reasonSectionCard(
                  context,
                  title: '核心亮点',
                  items: visibleHighlights,
                  icon: Icons.check_circle_outline_rounded,
                  color: t.success,
                ),
              ),
            if (grouped.risks.isNotEmpty)
              SectionReveal(
                delay: const Duration(milliseconds: 90),
                child: _reasonSectionCard(
                  context,
                  title: '需要留意',
                  items: visibleRisks,
                  icon: Icons.warning_amber_rounded,
                  color: t.warning,
                ),
              ),
            if (grouped.highlights.isEmpty && grouped.risks.isEmpty)
              ...List.generate(data.reasons.length, (index) {
                return SectionReveal(
                  delay: Duration(milliseconds: 40 * (index + 1)),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MatchReasonCard(
                      reason: '${_reasonHeadline(index)}\n${data.reasons[index]}',
                    ),
                  ),
                );
              }),
            if (data.moduleScores.isNotEmpty)
              SectionReveal(
                delay: const Duration(milliseconds: 180),
                child: Container(
                  margin: EdgeInsets.only(bottom: t.spacing.sm),
                  padding: EdgeInsets.all(t.spacing.cardPadding),
                  decoration: BoxDecoration(
                    color: t.browseSurface,
                    borderRadius: BorderRadius.circular(t.radius.lg),
                    border: Border.all(color: t.browseBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '分项解释分',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      ...data.moduleScores.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            '${e.key}: ${e.value}分',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: t.textSecondary,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (data.moduleInsights.isNotEmpty)
              SectionReveal(
                delay: const Duration(milliseconds: 200),
                child: Container(
                  margin: EdgeInsets.only(bottom: t.spacing.sm),
                  padding: EdgeInsets.all(t.spacing.cardPadding),
                  decoration: BoxDecoration(
                    color: t.browseSurface,
                    borderRadius: BorderRadius.circular(t.radius.lg),
                    border: Border.all(color: t.browseBorder),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '模块解释',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      SizedBox(height: t.spacing.xs),
                      ...visibleInsights.map(
                        (line) {
                          final parsed = _parseInsightLine(line);
                          return MatchModuleInsightCard(
                            module: parsed.module,
                            score: parsed.score,
                            reason: parsed.reason,
                            risk: parsed.risk,
                            tags: parsed.tags,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            if (canExpand)
              SectionReveal(
                delay: const Duration(milliseconds: 205),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _expanded = !_expanded),
                      icon: Icon(_expanded ? Icons.unfold_less_rounded : Icons.unfold_more_rounded),
                      label: Text(_expanded ? '收起详情' : '展开全部'),
                    ),
                  ),
                ),
              ),
            if (glossaryEntries.isNotEmpty)
              SectionReveal(
                delay: const Duration(milliseconds: 210),
                child: MatchGlossaryCard(entries: glossaryEntries),
              ),
            SectionReveal(
              delay: const Duration(milliseconds: 220),
              child: MatchWeightBreakdown(weights: data.weights),
            ),
            ],
          );
        },
      ),
    );
  }
}
