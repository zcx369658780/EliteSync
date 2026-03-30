import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_evidence_reference_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_module_insight_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_reason_card.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_weight_breakdown.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class MatchDetailPage extends ConsumerStatefulWidget {
  const MatchDetailPage({super.key});

  @override
  ConsumerState<MatchDetailPage> createState() => _MatchDetailPageState();
}

class _MatchDetailPageState extends ConsumerState<MatchDetailPage> {
  bool _expanded = false;
  String _priorityFilter = 'all'; // all/high/medium/normal
  String _evidenceFilter = 'all'; // all/high/medium/low
  String _confidenceFilter = 'all'; // all/high/medium/low
  bool _showDevMetrics = false;
  final Map<String, GlobalKey> _moduleAnchorKeys = <String, GlobalKey>{};
  String _focusedModuleLabel = '';

  GlobalKey? _resolveModuleAnchorKey(String moduleLabel) {
    final exact = _moduleAnchorKeys[moduleLabel];
    if (exact != null) return exact;
    final normalizedTarget = moduleLabel
        .replaceAll(' ', '')
        .trim()
        .toLowerCase();
    for (final entry in _moduleAnchorKeys.entries) {
      final normalizedKey = entry.key.replaceAll(' ', '').trim().toLowerCase();
      if (normalizedKey == normalizedTarget) {
        return entry.value;
      }
    }
    return null;
  }

  void _focusWeakModule(String label) {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return;
    setState(() {
      _expanded = true;
      _priorityFilter = 'all';
      _evidenceFilter = 'low';
      _confidenceFilter = 'all';
      _focusedModuleLabel = trimmed;
    });
    Future<void>.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (_focusedModuleLabel == trimmed) {
        setState(() => _focusedModuleLabel = '');
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _resolveModuleAnchorKey(trimmed);
      final ctx = key?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.08,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('当前列表未找到该模块，请尝试切换筛选或展开全部'),
            duration: Duration(milliseconds: 1300),
          ),
        );
      }
    });
  }

  String _normalizeRiskLevel(Map<String, dynamic> row) {
    final level = (row['risk_level'] ?? '').toString().trim().toLowerCase();
    if (level == 'high' || level == 'medium' || level == 'low') return level;
    return _riskRank(row) >= 3
        ? 'high'
        : (_riskRank(row) >= 2 ? 'medium' : 'low');
  }

  String _riskSectionTitle(String level) {
    switch (level) {
      case 'high':
        return '高风险优先关注';
      case 'medium':
        return '中风险建议对齐';
      default:
        return '低风险可持续优化';
    }
  }

  String _normalizePriorityLevel(Map<String, dynamic> row) {
    final p = (row['priority_level'] ?? '').toString().trim().toLowerCase();
    if (p == 'high' || p == 'medium' || p == 'normal') return p;
    final priority = (row['priority'] as num?)?.toInt() ?? -1;
    if (priority >= 300) return 'high';
    if (priority >= 220) return 'medium';
    return 'normal';
  }

  Color _priorityColor(BuildContext context, String level) {
    final t = context.appTokens;
    if (level == 'high') return t.error;
    if (level == 'medium') return t.warning;
    return t.info;
  }

  String _priorityTitle(String level) {
    switch (level) {
      case 'high':
        return '优先关注';
      case 'medium':
        return '建议关注';
      default:
        return '常规关注';
    }
  }

  String _compatSectionTitle(String key) {
    switch (key) {
      case 'natal_compatibility':
        return '本命匹配层';
      case 'synastry':
        return '互动关系层';
      case 'composite_like':
        return '合盘气质层';
      default:
        return key;
    }
  }

  String _compatSectionHint(String key) {
    switch (key) {
      case 'natal_compatibility':
        return '看基础稳定与长期节律';
      case 'synastry':
        return '看相处过程与沟通节奏';
      case 'composite_like':
        return '看关系整体气质与共同体感';
      default:
        return '关系分层';
    }
  }

  int _riskRank(Map<String, dynamic> row) {
    final level = (row['risk_level'] ?? '').toString().trim().toLowerCase();
    if (level == 'high') return 3;
    if (level == 'medium') return 2;
    if (level == 'low') return 1;
    final risk = (row['risk'] ?? '').toString().trim();
    if (risk.isEmpty) return 0;
    if (risk.contains('高') ||
        risk.contains('冲') ||
        risk.contains('刑') ||
        risk.contains('害')) {
      return 3;
    }
    if (risk.contains('中') || risk.contains('磨合') || risk.contains('张力')) {
      return 2;
    }
    return 1;
  }

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

  List<String> _asStringList(dynamic raw) {
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (raw == null) return const [];
    final one = raw.toString().trim();
    return one.isEmpty ? const [] : [one];
  }

  Map<String, String> _asStringMap(dynamic raw) {
    if (raw is Map) {
      return raw.map(
        (k, v) => MapEntry(k.toString(), v.toString()),
      );
    }
    return const <String, String>{};
  }

  Map<String, dynamic> _asDynamicMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    return const <String, dynamic>{};
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

  ({String module, int score, String reason, String? risk, List<String> tags})
  _parseInsightLine(String line) {
    final trimmed = line.trim();
    final mainParts = trimmed.split('：');
    final title = mainParts.isNotEmpty ? mainParts.first.trim() : '匹配项';
    final body = mainParts.length > 1
        ? mainParts.sublist(1).join('：').trim()
        : '';

    final moduleMatch = RegExp(r'^(.+?)（(\d+)分）$').firstMatch(title);
    final module = moduleMatch?.group(1)?.trim() ?? title;
    final score = int.tryParse(moduleMatch?.group(2) ?? '') ?? 0;

    String reason = body;
    String? risk;
    List<String> tags = const [];

    final segments = body
        .split('；')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
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

  ({List<String> highlights, List<String> risks}) _groupReasons(
    List<String> reasons,
  ) {
    final highlights = <String>[];
    final risks = <String>[];
    for (final raw in reasons) {
      final line = raw.trim();
      if (line.isEmpty) continue;
      if (line.startsWith('需要留意') ||
          line.contains('风险') ||
          line.contains('张力')) {
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

  Widget _explanationBlockCard(
    BuildContext context, {
    required Map<String, dynamic> block,
  }) {
    final t = context.appTokens;
    final summary = (block['summary'] ?? '').toString().trim();
    final process = _asStringList(block['process']);
    final risks = _asStringList(block['risks']);
    final advice = _asStringList(block['advice']);
    final label = (block['label'] ?? '').toString().trim();
    final confidence = (block['confidence'] ?? '').toString().trim();
    final priority = (block['priority'] ?? '').toString().trim();

    if (summary.isEmpty && process.isEmpty && risks.isEmpty && advice.isEmpty) {
      return const SizedBox.shrink();
    }

    Widget section(String title, List<String> rows, Color color) {
      if (rows.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            ...rows.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '• $e',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              Expanded(
                child: Text(
                  label.isEmpty ? '模块解释' : label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (confidence.isNotEmpty)
                Text(
                  confidence.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.info,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              if (priority.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  priority.toUpperCase(),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: t.textPrimary,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          section('过程', process, t.info),
          section('风险', risks, t.warning),
          section('建议', advice, t.success),
        ],
      ),
    );
  }

  Widget _modulePriorityOverview(
    BuildContext context, {
    required List<Map<String, dynamic>> rows,
    required ValueChanged<String> onFilterChange,
  }) {
    final t = context.appTokens;
    if (rows.isEmpty) return const SizedBox.shrink();
    int high = 0;
    int medium = 0;
    int normal = 0;
    for (final row in rows) {
      final level = _normalizePriorityLevel(row);
      if (level == 'high') {
        high++;
      } else if (level == 'medium') {
        medium++;
      } else {
        normal++;
      }
    }
    Widget chip(String level, int count) {
      final color = _priorityColor(context, level);
      final selected = _priorityFilter == level;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.xs,
          vertical: t.spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.24 : 0.14),
          borderRadius: BorderRadius.circular(t.radius.pill),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.62 : 0.32),
          ),
        ),
        child: Text(
          '${_priorityTitle(level)} $count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      );
    }

    final top = rows.first;
    final topReason = (top['priority_reason'] ?? '').toString().trim();
    final topLabel = (top['label'] ?? '').toString().trim();
    final summary = topReason.isNotEmpty
        ? '当前最需关注：${topLabel.isEmpty ? "匹配项" : topLabel}（$topReason）'
        : '';

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
          Text(
            '关注分布',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('all'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: t.browseChip.withValues(
                      alpha: _priorityFilter == 'all' ? 0.30 : 0.16,
                    ),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: t.browseBorder.withValues(
                        alpha: _priorityFilter == 'all' ? 0.72 : 0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    '全部 ${rows.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: _priorityFilter == 'all'
                          ? FontWeight.w800
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('high'),
                child: chip('high', high),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('medium'),
                child: chip('medium', medium),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('normal'),
                child: chip('normal', normal),
              ),
            ],
          ),
          if (summary.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Text(
              summary,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _evidenceStrengthOverview(
    BuildContext context, {
    required List<Map<String, dynamic>> rows,
    Map<String, dynamic> summary = const {},
    required ValueChanged<String> onFilterChange,
    required ValueChanged<String> onWeakModuleTap,
  }) {
    final t = context.appTokens;
    if (rows.isEmpty) return const SizedBox.shrink();
    int high = (summary['high'] as num?)?.toInt() ?? 0;
    int medium = (summary['medium'] as num?)?.toInt() ?? 0;
    int low = (summary['low'] as num?)?.toInt() ?? 0;
    final weakModulesRaw =
        (summary['weak_modules'] as List<dynamic>? ?? const []);
    final weakModulesFromServer = weakModulesRaw
        .map((e) {
          if (e is Map<String, dynamic>) {
            final label = (e['label'] ?? '').toString().trim();
            if (label.isEmpty) return '';
            final rank = (e['priority_rank'] as num?)?.toInt() ?? 0;
            final reason = (e['reason'] ?? '').toString().trim();
            final prefix = rank > 0 ? 'TOP$rank ' : '';
            if (reason.isEmpty) return '$prefix$label'.trim();
            return '$prefix$label（$reason）'.trim();
          }
          return e.toString().trim();
        })
        .where((e) => e.isNotEmpty)
        .toList();
    final weakModuleLabels = weakModulesRaw
        .map(
          (e) => e is Map<String, dynamic>
              ? (e['label'] ?? '').toString().trim()
              : e.toString().trim(),
        )
        .where((e) => e.isNotEmpty)
        .toList();
    final hasServerSummary = summary.isNotEmpty && (high + medium + low) > 0;
    if (!hasServerSummary) {
      high = 0;
      medium = 0;
      low = 0;
      for (final row in rows) {
        final level = (row['evidence_strength'] ?? '')
            .toString()
            .trim()
            .toLowerCase();
        if (level == 'high') {
          high++;
        } else if (level == 'medium') {
          medium++;
        } else {
          low++;
        }
      }
    }

    final weakModules = <Map<String, String>>[];
    String topSummary;
    if (weakModulesFromServer.isNotEmpty) {
      if (weakModuleLabels.isNotEmpty) {
        for (var i = 0; i < weakModuleLabels.length; i++) {
          weakModules.add({
            'label': weakModuleLabels[i],
            'tooltip': i < weakModulesFromServer.length
                ? weakModulesFromServer[i]
                : weakModuleLabels[i],
          });
        }
      } else {
        for (final item in weakModulesFromServer) {
          weakModules.add({'label': item, 'tooltip': item});
        }
      }
      topSummary = '当前最需补强证据：${weakModulesFromServer.join("、")}';
    } else {
      final top = rows.firstWhere(
        (r) =>
            (r['evidence_strength'] ?? '').toString().trim().toLowerCase() ==
            'low',
        orElse: () => rows.first,
      );
      final fallbackWeak = rows
          .where(
            (r) =>
                (r['evidence_strength'] ?? '')
                    .toString()
                    .trim()
                    .toLowerCase() ==
                'low',
          )
          .map((r) => (r['label'] ?? '').toString().trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .take(3)
          .toList();
      for (final item in fallbackWeak) {
        weakModules.add({'label': item, 'tooltip': item});
      }
      final topLabel = (top['label'] ?? '').toString().trim();
      final topReason = (top['evidence_strength_reason'] ?? '')
          .toString()
          .trim();
      topSummary = topReason.isEmpty
          ? '当前最需补强证据：${topLabel.isEmpty ? "匹配项" : topLabel}'
          : '当前最需补强证据：${topLabel.isEmpty ? "匹配项" : topLabel}（$topReason）';
    }

    Widget chip({
      required String key,
      required String label,
      required int count,
      required Color color,
    }) {
      final selected = _evidenceFilter == key;
      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: t.spacing.xs,
          vertical: t.spacing.xxs,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: selected ? 0.24 : 0.15),
          borderRadius: BorderRadius.circular(t.radius.pill),
          border: Border.all(
            color: color.withValues(alpha: selected ? 0.62 : 0.33),
          ),
        ),
        child: Text(
          '$label $count',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      );
    }

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
          Text(
            '证据强度分布',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('all'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: t.browseChip.withValues(
                      alpha: _evidenceFilter == 'all' ? 0.30 : 0.16,
                    ),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: t.browseBorder.withValues(
                        alpha: _evidenceFilter == 'all' ? 0.72 : 0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    '全部 ${rows.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: _evidenceFilter == 'all'
                          ? FontWeight.w800
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('high'),
                child: chip(
                  key: 'high',
                  label: '证据强',
                  count: high,
                  color: t.success,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('medium'),
                child: chip(
                  key: 'medium',
                  label: '证据中',
                  count: medium,
                  color: t.warning,
                ),
              ),
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('low'),
                child: chip(
                  key: 'low',
                  label: '证据弱',
                  count: low,
                  color: t.error,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            topSummary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (weakModules.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: weakModules
                  .map(
                    (m) => Tooltip(
                      message: m['tooltip'] ?? '',
                      child: ActionChip(
                        label: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text(
                            m['label'] ?? '',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        onPressed: () => onWeakModuleTap(m['label'] ?? ''),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  String _priorityFilterLabel() {
    switch (_priorityFilter) {
      case 'high':
        return '优先关注';
      case 'medium':
        return '建议关注';
      case 'normal':
        return '常规关注';
      default:
        return '全部关注级别';
    }
  }

  String _evidenceFilterLabel() {
    switch (_evidenceFilter) {
      case 'high':
        return '证据强';
      case 'medium':
        return '证据中';
      case 'low':
        return '证据弱';
      default:
        return '全部证据强度';
    }
  }

  String _confidenceFilterLabel() {
    switch (_confidenceFilter) {
      case 'high':
        return '高置信';
      case 'medium':
        return '中置信';
      case 'low':
        return '低置信';
      default:
        return '全部置信等级';
    }
  }

  Widget _confidenceTierOverview(
    BuildContext context, {
    required List<Map<String, dynamic>> rows,
    required ValueChanged<String> onFilterChange,
  }) {
    final t = context.appTokens;
    final high = rows
        .where(
          (e) =>
              (e['confidence_tier'] ?? '').toString().trim().toLowerCase() ==
              'high',
        )
        .length;
    final medium = rows
        .where(
          (e) =>
              (e['confidence_tier'] ?? '').toString().trim().toLowerCase() ==
              'medium',
        )
        .length;
    final low = rows
        .where(
          (e) =>
              (e['confidence_tier'] ?? '').toString().trim().toLowerCase() ==
              'low',
        )
        .length;

    Widget chip({
      required String key,
      required String label,
      required int count,
      required Color color,
    }) {
      final selected = _confidenceFilter == key;
      return InkWell(
        borderRadius: BorderRadius.circular(t.radius.pill),
        onTap: () => onFilterChange(key),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: t.spacing.xs,
            vertical: t.spacing.xxs,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: selected ? 0.24 : 0.15),
            borderRadius: BorderRadius.circular(t.radius.pill),
            border: Border.all(
              color: color.withValues(alpha: selected ? 0.62 : 0.33),
            ),
          ),
          child: Text(
            '$label $count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ),
      );
    }

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
          Text(
            '置信等级分布',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(t.radius.pill),
                onTap: () => onFilterChange('all'),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: t.browseChip.withValues(
                      alpha: _confidenceFilter == 'all' ? 0.30 : 0.16,
                    ),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: t.browseBorder.withValues(
                        alpha: _confidenceFilter == 'all' ? 0.72 : 0.35,
                      ),
                    ),
                  ),
                  child: Text(
                    '全部 ${rows.length}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: _confidenceFilter == 'all'
                          ? FontWeight.w800
                          : FontWeight.w700,
                    ),
                  ),
                ),
              ),
              chip(key: 'high', label: '高置信', count: high, color: t.success),
              chip(
                key: 'medium',
                label: '中置信',
                count: medium,
                color: t.warning,
              ),
              chip(key: 'low', label: '低置信', count: low, color: t.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _activeFilterSummary(BuildContext context) {
    final t = context.appTokens;
    final hasFilter =
        _priorityFilter != 'all' ||
        _evidenceFilter != 'all' ||
        _confidenceFilter != 'all';
    if (!hasFilter) return const SizedBox.shrink();
    return Container(
      margin: EdgeInsets.only(bottom: t.spacing.sm),
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.cardPadding,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: t.browseChip.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '当前筛选：${_priorityFilterLabel()} / ${_evidenceFilterLabel()} / ${_confidenceFilterLabel()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _priorityFilter = 'all';
                _evidenceFilter = 'all';
                _confidenceFilter = 'all';
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('已重置筛选'),
                  duration: Duration(milliseconds: 900),
                ),
              );
            },
            child: const Text('清空筛选'),
          ),
        ],
      ),
    );
  }

  String _buildDebugSnapshot(List<Map<String, dynamic>> rows) {
    final buffer = StringBuffer();
    buffer.writeln('MatchDetail Debug Snapshot');
    for (final row in rows) {
      final label = (row['label'] ?? '匹配项').toString();
      final score = (row['score'] as num?)?.toInt() ?? 0;
      final priority = (row['priority'] as num?)?.toInt() ?? -1;
      final priorityLevel = (row['priority_level'] ?? 'normal').toString();
      final confidence = ((row['confidence'] as num?)?.toDouble() ?? 0.5) * 100;
      final degraded = ((row['degraded'] as bool?) ?? false) ? 1 : 0;
      final riskLevel = (row['risk_level'] ?? 'low').toString();
      buffer.writeln(
        '$label | score=$score | p=$priority($priorityLevel) | conf=${confidence.toStringAsFixed(0)}% | risk=$riskLevel | degraded=$degraded',
      );
    }
    return buffer.toString().trim();
  }

  List<MatchEvidenceReferenceSection> _buildReferenceSections(
    List<Map<String, dynamic>> rows,
  ) {
    final sections = <MatchEvidenceReferenceSection>[];
    for (final row in rows) {
      final coreRefs =
          (row['core_tag_refs'] as Map<String, dynamic>? ?? const {}).values
              .map((e) => e.toString().trim())
              .where((e) => e.isNotEmpty)
              .toList();
      final auxRefs = (row['aux_tag_refs'] as Map<String, dynamic>? ?? const {})
          .values
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
      final refs = <String>[];
      for (final item in [...coreRefs, ...auxRefs]) {
        if (!refs.contains(item)) refs.add(item);
      }
      if (refs.isEmpty) continue;
      final moduleLabel = (row['label'] ?? '匹配项').toString().trim();
      final priorityLevel = _normalizePriorityLevel(row);
      final rank = (row['priority_rank'] as num?)?.toInt() ?? 0;
      sections.add(
        MatchEvidenceReferenceSection(
          moduleLabel: moduleLabel.isEmpty ? '匹配项' : moduleLabel,
          priorityLevel: priorityLevel,
          rank: rank <= 0 ? sections.length + 1 : rank,
          references: refs,
        ),
      );
    }
    return sections;
  }

  String _buildModuleDebugText(Map<String, dynamic> row) {
    final label = (row['label'] ?? '匹配项').toString().trim();
    final score = (row['score'] as num?)?.toInt() ?? 0;
    final priority = (row['priority'] as num?)?.toInt() ?? -1;
    final priorityLevel = (row['priority_level'] ?? 'normal').toString();
    final priorityRank = (row['priority_rank'] as num?)?.toInt() ?? 0;
    final confidence = ((row['confidence'] as num?)?.toDouble() ?? 0.5) * 100;
    final degraded = ((row['degraded'] as bool?) ?? false) ? 1 : 0;
    final riskLevel = (row['risk_level'] ?? 'low').toString();
    final risk = (row['risk'] ?? '').toString().trim();
    final reason = (row['reason'] ?? '').toString().trim();
    final tags = (row['tags'] as List<dynamic>? ?? const [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .join('、');
    final engineSource = (row['engine_source'] ?? '').toString().trim();
    final engineMode = (row['engine_mode'] ?? '').toString().trim();
    final dataQuality = (row['data_quality'] ?? '').toString().trim();
    final precisionLevel = (row['precision_level'] ?? '').toString().trim();
    final confidenceReasons =
        (row['confidence_reason'] as List<dynamic>? ?? const [])
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .join('|');
    final guard = (row['display_guard'] as Map<String, dynamic>? ?? const {});
    final hc = (guard['allow_high_confidence_badge'] as bool?) ?? false;
    final se = (guard['allow_strong_evidence_badge'] as bool?) ?? false;
    final pw = (guard['allow_precise_wording'] as bool?) ?? false;
    return [
      '$label | score=$score',
      'priority=$priority($priorityLevel)',
      if (priorityRank > 0) 'rank=TOP$priorityRank',
      'confidence=${confidence.toStringAsFixed(0)}%',
      'risk_level=$riskLevel',
      if (risk.isNotEmpty) 'risk=$risk',
      if (tags.isNotEmpty) 'tags=$tags',
      if (engineSource.isNotEmpty) 'engine_source=$engineSource',
      if (engineMode.isNotEmpty) 'engine_mode=$engineMode',
      if (dataQuality.isNotEmpty) 'data_quality=$dataQuality',
      if (precisionLevel.isNotEmpty) 'precision=$precisionLevel',
      if (confidenceReasons.isNotEmpty) 'confidence_reason=$confidenceReasons',
      if (guard.isNotEmpty) 'guard(HC/SE/PW)=${hc ? 1 : 0}/${se ? 1 : 0}/${pw ? 1 : 0}',
      'degraded=$degraded',
      if (reason.isNotEmpty) 'reason=$reason',
    ].join(' | ');
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(matchDetailProvider);
    final t = context.appTokens;
    final env = ref.watch(appEnvProvider);

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
        error: (e, _) =>
            AppErrorState(title: '详情加载失败', description: e.toString()),
        data: (data) {
          final grouped = _groupReasons(data.reasons);
          final maxReasonCount = _expanded ? 99 : 3;
          final maxInsightCount = _expanded ? 99 : 3;
          final visibleHighlights = grouped.highlights
              .take(maxReasonCount)
              .toList();
          final visibleRisks = grouped.risks.take(maxReasonCount).toList();
          final visibleInsights = data.moduleInsights
              .take(maxInsightCount)
              .toList();
          final explanationBlocksAll = data.explanationBlocks
              .where((e) {
                final summary = (e['summary'] ?? '').toString().trim();
                final process = (e['process'] as List<dynamic>? ?? const []);
                final risks = (e['risks'] as List<dynamic>? ?? const []);
                final advice = (e['advice'] as List<dynamic>? ?? const []);
                return summary.isNotEmpty ||
                    process.isNotEmpty ||
                    risks.isNotEmpty ||
                    advice.isNotEmpty;
              })
              .toList();
          final visibleExplanationBlocks = explanationBlocksAll
              .take(maxInsightCount)
              .toList();
          final hasExplanationBlocks = visibleExplanationBlocks.isNotEmpty;
          final explanationRowsAll =
              data.moduleExplanations
                  .where(
                    (e) => ((e['label'] ?? '').toString().trim().isNotEmpty),
                  )
                  .toList()
                ..sort((a, b) {
                  final pa = (a['priority'] as num?)?.toInt() ?? -1;
                  final pb = (b['priority'] as num?)?.toInt() ?? -1;
                  if (pa != pb) {
                    return pb.compareTo(pa); // server priority first
                  }
                  final ra = _riskRank(a);
                  final rb = _riskRank(b);
                  if (ra != rb) return rb.compareTo(ra); // high-risk first
                  final ca = (a['confidence'] as num?)?.toDouble() ?? 0.5;
                  final cb = (b['confidence'] as num?)?.toDouble() ?? 0.5;
                  if (ca != cb) {
                    return ca.compareTo(cb); // lower confidence first
                  }
                  final sa = (a['score'] as num?)?.toInt() ?? 0;
                  final sb = (b['score'] as num?)?.toInt() ?? 0;
                  return sa.compareTo(sb); // then low-score first
                });
          final visibleExplanationRows = explanationRowsAll
              .take(maxInsightCount)
              .toList();
          final filteredExplanationRows = _priorityFilter == 'all'
              ? visibleExplanationRows
              : visibleExplanationRows
                    .where((e) => _normalizePriorityLevel(e) == _priorityFilter)
                    .toList();
          final evidenceFilteredRows = _evidenceFilter == 'all'
              ? filteredExplanationRows
              : filteredExplanationRows
                    .where(
                      (e) =>
                          (e['evidence_strength'] ?? '')
                              .toString()
                              .trim()
                              .toLowerCase() ==
                          _evidenceFilter,
                    )
                    .toList();
          final confidenceFilteredRows = _confidenceFilter == 'all'
              ? evidenceFilteredRows
              : evidenceFilteredRows
                    .where(
                      (e) =>
                          (e['confidence_tier'] ?? '')
                              .toString()
                              .trim()
                              .toLowerCase() ==
                          _confidenceFilter,
                    )
                    .toList();
          final referenceSections = _buildReferenceSections(
            confidenceFilteredRows,
          );
          final groupedExplanations = <String, List<Map<String, dynamic>>>{
            'high': [],
            'medium': [],
            'low': [],
          };
          final anchoredLabels = <String>{};
          for (final row in confidenceFilteredRows) {
            groupedExplanations[_normalizeRiskLevel(row)]!.add(row);
          }
          final hasMoreReasons =
              !hasExplanationBlocks &&
              (grouped.highlights.length > visibleHighlights.length ||
                  grouped.risks.length > visibleRisks.length);
          final hasMoreInsights = explanationRowsAll.isNotEmpty
              ? explanationRowsAll.length > visibleExplanationRows.length
              : data.moduleInsights.length > visibleInsights.length;
          final hasMoreExplanationBlocks =
              explanationBlocksAll.length > visibleExplanationBlocks.length;
          final canExpand =
              hasMoreReasons || hasMoreInsights || hasMoreExplanationBlocks;
          final compatibilitySections = data.compatibilitySections.entries
              .where((entry) => entry.value.isNotEmpty)
              .toList();
          final hasRenderableContent =
              visibleHighlights.isNotEmpty ||
              visibleRisks.isNotEmpty ||
              visibleExplanationBlocks.isNotEmpty ||
              compatibilitySections.isNotEmpty ||
              data.moduleScores.isNotEmpty ||
              visibleExplanationRows.isNotEmpty ||
              visibleInsights.isNotEmpty;
          final summaryRows = <String>[
            if (data.reasons.isNotEmpty) '原因数: ${data.reasons.length}',
            if (data.weights.isNotEmpty) '权重项: ${data.weights.length}',
            if (data.moduleScores.isNotEmpty) '分项数: ${data.moduleScores.length}',
            if (data.moduleInsights.isNotEmpty) '模块说明: ${data.moduleInsights.length}',
            if (data.moduleExplanations.isNotEmpty) '解释项: ${data.moduleExplanations.length}',
            if (data.explanationBlocks.isNotEmpty) '解释块: ${data.explanationBlocks.length}',
          ];
          final mergedGlossary = <String, String>{
            ..._termGlossary,
            ...data.reasonGlossary,
          };
          final blockTexts = <String>[
            for (final b in visibleExplanationBlocks)
              (b['summary'] ?? '').toString(),
            for (final b in visibleExplanationBlocks)
              ...((b['process'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())),
            for (final b in visibleExplanationBlocks)
              ...((b['risks'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())),
            for (final b in visibleExplanationBlocks)
              ...((b['advice'] as List<dynamic>? ?? const [])
                  .map((e) => e.toString())),
          ];
          final glossaryEntries = _collectGlossary(
            hasExplanationBlocks ? blockTexts : [...data.reasons, ...visibleInsights],
            serverGlossary: data.reasonGlossary,
          );
          return ListView(
            padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
            children: [
              const SectionReveal(
                child: PageTitleRail(title: '匹配解释', subtitle: '先看关系解释，再看参数补充'),
              ),
              SizedBox(height: t.spacing.md),
              SectionReveal(
                delay: const Duration(milliseconds: 20),
                child: Container(
                  width: double.infinity,
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
                        '匹配摘要',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (summaryRows.isEmpty)
                        Text(
                          '当前结果已返回，但摘要暂未解析出结构化内容。请向下继续查看原始说明。',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                        )
                      else
                        ...summaryRows.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (data.reasons.isNotEmpty && visibleExplanationRows.isEmpty)
                SectionReveal(
                  delay: const Duration(milliseconds: 40),
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
                          '基础匹配说明',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...data.reasons.map(
                          (line) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              line,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: t.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!hasRenderableContent)
                SectionReveal(
                  delay: const Duration(milliseconds: 50),
                  child: Container(
                    width: double.infinity,
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
                          '当前解释暂不可展开',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: t.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '当前版本已收到了匹配结果，但解释块尚未完整返回。你可以先查看基础原因与分项解释，后续再刷新重试。',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!hasExplanationBlocks && grouped.highlights.isNotEmpty)
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
              if (!hasExplanationBlocks && grouped.risks.isNotEmpty)
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
              if (!hasExplanationBlocks &&
                  grouped.highlights.isEmpty &&
                  grouped.risks.isEmpty)
                ...List.generate(data.reasons.length, (index) {
                  return SectionReveal(
                    delay: Duration(milliseconds: 40 * (index + 1)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: MatchReasonCard(
                        reason:
                            '${_reasonHeadline(index)}\n${data.reasons[index]}',
                      ),
                    ),
                  );
                }),
              if (visibleExplanationBlocks.isNotEmpty)
                SectionReveal(
                  delay: const Duration(milliseconds: 140),
                  child: Column(
                    children: visibleExplanationBlocks
                        .map(
                          (row) => _explanationBlockCard(
                            context,
                            block: row,
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (compatibilitySections.isNotEmpty)
                SectionReveal(
                  delay: const Duration(milliseconds: 160),
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
                          '关系分层',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xs),
                        ...compatibilitySections.map((entry) {
                          final rows = entry.value;
                final avg = rows.isEmpty
                              ? 0
                              : (rows
                                            .map(
                                              (e) =>
                                                  (e['score'] as num?)
                                                      ?.toInt() ??
                                                  0,
                                            )
                                            .reduce((a, b) => a + b) /
                                        rows.length)
                                    .round();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _compatSectionTitle(entry.key),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: t.textPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _compatSectionHint(entry.key),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: t.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.browseSurface.withValues(
                                      alpha: 0.78,
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(color: t.browseBorder),
                                  ),
                                  child: Text(
                                    '$avg分 · ${rows.length}项',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: t.textPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
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
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: t.textSecondary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (data.moduleInsights.isNotEmpty ||
                  data.moduleExplanations.isNotEmpty)
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
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xs),
                        if (env.isDev)
                          Padding(
                            padding: EdgeInsets.only(bottom: t.spacing.xs),
                            child: Row(
                              children: [
                                TextButton.icon(
                                  onPressed: () => setState(
                                    () => _showDevMetrics = !_showDevMetrics,
                                  ),
                                  icon: Icon(
                                    _showDevMetrics
                                        ? Icons.bug_report_rounded
                                        : Icons.bug_report_outlined,
                                    size: 18,
                                  ),
                                  label: Text(
                                    _showDevMetrics ? '关闭调试指标' : '显示调试指标',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton.icon(
                                  onPressed: visibleExplanationRows.isEmpty
                                      ? null
                                      : () async {
                                          final text = _buildDebugSnapshot(
                                            visibleExplanationRows,
                                          );
                                          await Clipboard.setData(
                                            ClipboardData(text: text),
                                          );
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text('已复制调试快照'),
                                              ),
                                            );
                                          }
                                        },
                                  icon: const Icon(
                                    Icons.copy_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('复制调试快照'),
                                ),
                              ],
                            ),
                          ),
                        if (visibleExplanationRows.isNotEmpty)
                          _evidenceStrengthOverview(
                            context,
                            rows: visibleExplanationRows,
                            summary: data.evidenceStrengthSummary,
                            onFilterChange: (v) =>
                                setState(() => _evidenceFilter = v),
                            onWeakModuleTap: _focusWeakModule,
                          ),
                        if (visibleExplanationRows.isNotEmpty)
                          _modulePriorityOverview(
                            context,
                            rows: visibleExplanationRows,
                            onFilterChange: (v) =>
                                setState(() => _priorityFilter = v),
                          ),
                        if (visibleExplanationRows.isNotEmpty)
                          _confidenceTierOverview(
                            context,
                            rows: visibleExplanationRows,
                            onFilterChange: (v) =>
                                setState(() => _confidenceFilter = v),
                          ),
                        _activeFilterSummary(context),
                        if (confidenceFilteredRows.isNotEmpty)
                          ...['high', 'medium', 'low'].expand((level) {
                            final rows =
                                groupedExplanations[level] ??
                                const <Map<String, dynamic>>[];
                            if (rows.isEmpty) return const <Widget>[];
                            return <Widget>[
                              Padding(
                                padding: EdgeInsets.only(
                                  top: level == 'high' ? 0 : t.spacing.xs,
                                  bottom: t.spacing.xs,
                                ),
                                child: Text(
                                  _riskSectionTitle(level),
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                              ...rows.map((row) {
                                final module = (row['label'] ?? '')
                                    .toString()
                                    .trim();
                                final score =
                                    (row['score'] as num?)?.toInt() ?? 0;
                                final confidence = (row['confidence'] as num?)
                                    ?.toDouble();
                                final confidenceTier =
                                    (row['confidence_tier'] ?? '')
                                        .toString()
                                        .trim()
                                        .toLowerCase();
                                final degraded =
                                    (row['degraded'] as bool?) ?? false;
                                final degradeReason =
                                    (row['degrade_reason'] ?? '')
                                        .toString()
                                        .trim();
                                final priority = (row['priority'] as num?)
                                    ?.toInt();
                                final priorityRank =
                                    (row['priority_rank'] as num?)?.toInt();
                                final priorityLevel =
                                    (row['priority_level'] ?? '')
                                        .toString()
                                        .trim();
                                final priorityReason =
                                    (row['priority_reason'] ?? '')
                                        .toString()
                                        .trim();
                                final engineSource =
                                    (row['engine_source'] ?? '')
                                        .toString()
                                        .trim();
                                final engineMode = (row['engine_mode'] ?? '')
                                    .toString()
                                    .trim();
                                final dataQuality =
                                    (row['data_quality'] ?? '')
                                        .toString()
                                        .trim();
                                final precisionLevel =
                                    (row['precision_level'] ?? '')
                                        .toString()
                                        .trim();
                                final confidenceReasons =
                                    _asStringList(row['confidence_reason']);
                                final displayGuard = _asDynamicMap(
                                  row['display_guard'],
                                );
                                final evidenceStrength =
                                    (row['evidence_strength'] ?? '')
                                        .toString()
                                        .trim();
                                final evidenceStrengthReason =
                                    (row['evidence_strength_reason'] ?? '')
                                        .toString()
                                        .trim();
                                final reason = (row['reason'] ?? '暂无说明')
                                    .toString()
                                    .trim();
                                final riskRaw = (row['risk'] ?? '')
                                    .toString()
                                    .trim();
                                final riskLevel = _normalizeRiskLevel(row);
                                final tags = _asStringList(row['tags']);
                                final coreTags = _asStringList(row['core_tags']);
                                final auxTags = _asStringList(row['aux_tags']);
                                final coreTagExplains = _asStringMap(
                                  row['core_tag_explains'],
                                );
                                final auxTagExplains = _asStringMap(
                                  row['aux_tag_explains'],
                                );
                                final coreTagRefs = _asStringMap(
                                  row['core_tag_refs'],
                                );
                                final auxTagRefs = _asStringMap(
                                  row['aux_tag_refs'],
                                );
                                final moduleLabel = module.isEmpty
                                    ? '匹配项'
                                    : module;
                                final shouldAnchor = !anchoredLabels.contains(
                                  moduleLabel,
                                );
                                if (shouldAnchor) {
                                  anchoredLabels.add(moduleLabel);
                                }
                                final highlighted =
                                    _focusedModuleLabel.isNotEmpty &&
                                    moduleLabel == _focusedModuleLabel;
                                return MatchModuleInsightCard(
                                  key: shouldAnchor
                                      ? (_moduleAnchorKeys[moduleLabel] ??=
                                            GlobalKey())
                                      : null,
                                  module: moduleLabel,
                                  score: score,
                                  reason: reason.isEmpty ? '暂无说明' : reason,
                                  risk: riskRaw.isEmpty ? null : riskRaw,
                                  riskLevel: riskLevel,
                                  confidence: confidence,
                                  confidenceTier: confidenceTier.isEmpty
                                      ? null
                                      : confidenceTier,
                                  degraded: degraded,
                                  degradeReason: degradeReason.isEmpty
                                      ? null
                                      : degradeReason,
                                  priority: priority,
                                  priorityRank: priorityRank,
                                  priorityLevel: priorityLevel.isEmpty
                                      ? null
                                      : priorityLevel,
                                  priorityReason: priorityReason.isEmpty
                                      ? null
                                      : priorityReason,
                                  evidenceStrength: evidenceStrength.isEmpty
                                      ? null
                                      : evidenceStrength,
                                  evidenceStrengthReason:
                                      evidenceStrengthReason.isEmpty
                                      ? null
                                      : evidenceStrengthReason,
                                  highlighted: highlighted,
                                  showDebugMeta: env.isDev && _showDevMetrics,
                                  debugCopyText: _buildModuleDebugText(row),
                                  engineSource: engineSource.isEmpty
                                      ? null
                                      : engineSource,
                                  engineMode: engineMode.isEmpty
                                      ? null
                                      : engineMode,
                                  dataQuality: dataQuality.isEmpty
                                      ? null
                                      : dataQuality,
                                  precisionLevel: precisionLevel.isEmpty
                                      ? null
                                      : precisionLevel,
                                  confidenceReasons: confidenceReasons,
                                  displayGuard: displayGuard,
                                  tags: tags,
                                  coreTags: coreTags,
                                  auxTags: auxTags,
                                  coreTagExplains: coreTagExplains,
                                  auxTagExplains: auxTagExplains,
                                  coreTagRefs: coreTagRefs,
                                  auxTagRefs: auxTagRefs,
                                  glossary: mergedGlossary,
                                );
                              }),
                            ];
                          })
                        else if (visibleExplanationRows.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: t.spacing.xs),
                            padding: EdgeInsets.all(t.spacing.cardPadding),
                            decoration: BoxDecoration(
                              color: t.browseChip.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(t.radius.md),
                              border: Border.all(color: t.browseBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '当前筛选无结果',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '试试切换到“全部”或其他证据/关注级别查看模块解释。',
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xs),
                                TextButton(
                                  onPressed: () => setState(() {
                                    _priorityFilter = 'all';
                                    _evidenceFilter = 'all';
                                    _confidenceFilter = 'all';
                                  }),
                                  child: const Text('重置为全部'),
                                ),
                              ],
                            ),
                          )
                        else if (data.moduleExplanations.isNotEmpty ||
                            data.moduleInsights.isNotEmpty ||
                            data.explanationBlocks.isNotEmpty)
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.only(bottom: t.spacing.xs),
                            padding: EdgeInsets.all(t.spacing.cardPadding),
                            decoration: BoxDecoration(
                              color: t.browseChip.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(t.radius.md),
                              border: Border.all(color: t.browseBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '解释已加载',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: t.textPrimary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                SizedBox(height: t.spacing.xxs),
                                Text(
                                  '当前结果已返回说明内容，但本次筛选条件下没有可直接展开的模块卡。你可以点“展开全部”查看完整内容。',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ),
                          )
                        else
                          ...visibleInsights.map((line) {
                            final parsed = _parseInsightLine(line);
                            return MatchModuleInsightCard(
                              module: parsed.module,
                              score: parsed.score,
                              reason: parsed.reason,
                              risk: parsed.risk,
                              confidence: null,
                              confidenceTier: null,
                              degraded: false,
                              priority: null,
                              priorityRank: null,
                              priorityLevel: null,
                              priorityReason: null,
                              evidenceStrength: null,
                              evidenceStrengthReason: null,
                              highlighted:
                                  _focusedModuleLabel.isNotEmpty &&
                                  parsed.module == _focusedModuleLabel,
                              showDebugMeta: env.isDev && _showDevMetrics,
                              debugCopyText:
                                  '${parsed.module} | score=${parsed.score} | reason=${parsed.reason}',
                              engineSource: null,
                              engineMode: null,
                              dataQuality: null,
                              precisionLevel: null,
                              confidenceReasons: const [],
                              displayGuard: const {},
                              tags: parsed.tags,
                              glossary: mergedGlossary,
                            );
                          }),
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
                        icon: Icon(
                          _expanded
                              ? Icons.unfold_less_rounded
                              : Icons.unfold_more_rounded,
                        ),
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
              if (referenceSections.isNotEmpty)
                SectionReveal(
                  delay: const Duration(milliseconds: 215),
                  child: MatchEvidenceReferenceCard(
                    sections: referenceSections,
                  ),
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
