import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchModuleInsightCard extends StatelessWidget {
  const MatchModuleInsightCard({
    super.key,
    required this.module,
    required this.score,
    required this.reason,
    this.risk,
    this.riskLevel,
    this.confidence,
    this.confidenceTier,
    this.degraded = false,
    this.degradeReason,
    this.priority,
    this.priorityRank,
    this.priorityLevel,
    this.priorityReason,
    this.evidenceStrength,
    this.evidenceStrengthReason,
    this.highlighted = false,
    this.showDebugMeta = false,
    this.debugCopyText,
    this.tags = const [],
    this.coreTags = const [],
    this.auxTags = const [],
    this.coreTagExplains = const {},
    this.auxTagExplains = const {},
    this.coreTagRefs = const {},
    this.auxTagRefs = const {},
    this.glossary = const {},
  });

  final String module;
  final int score;
  final String reason;
  final String? risk;
  final String? riskLevel;
  final double? confidence;
  final String? confidenceTier;
  final bool degraded;
  final String? degradeReason;
  final int? priority;
  final int? priorityRank;
  final String? priorityLevel;
  final String? priorityReason;
  final String? evidenceStrength;
  final String? evidenceStrengthReason;
  final bool highlighted;
  final bool showDebugMeta;
  final String? debugCopyText;
  final List<String> tags;
  final List<String> coreTags;
  final List<String> auxTags;
  final Map<String, String> coreTagExplains;
  final Map<String, String> auxTagExplains;
  final Map<String, String> coreTagRefs;
  final Map<String, String> auxTagRefs;
  final Map<String, String> glossary;

  Color _scoreColor(BuildContext context) {
    final t = context.appTokens;
    // Continuous scale: 50 -> error(red), 75 -> warning, 100 -> success(green)
    final normalized = ((score.clamp(50, 100) - 50) / 50.0).clamp(0.0, 1.0);
    final Color pivot = Color.lerp(t.error, t.warning, 0.5) ?? t.warning;
    if (normalized < 0.5) {
      return Color.lerp(t.error, pivot, normalized / 0.5) ?? t.error;
    }
    return Color.lerp(pivot, t.success, (normalized - 0.5) / 0.5) ?? t.success;
  }

  Color _riskColor(BuildContext context) {
    final t = context.appTokens;
    final v = (riskLevel ?? '').trim().toLowerCase();
    if (v == 'high') return t.error;
    if (v == 'medium') return t.warning;
    return t.info;
  }

  String _riskLabel() {
    final v = (riskLevel ?? '').trim().toLowerCase();
    if (v == 'high') return '高风险';
    if (v == 'medium') return '中风险';
    return '低风险';
  }

  String _confidenceLabel() {
    final tier = (confidenceTier ?? '').trim().toLowerCase();
    if (tier == 'high') return '高置信';
    if (tier == 'medium') return '中置信';
    if (tier == 'low') return '低置信';
    final c = (confidence ?? 0.5).clamp(0.0, 1.0);
    if (c >= 0.8) return '高置信';
    if (c >= 0.6) return '中置信';
    return '低置信';
  }

  Color _confidenceColor(BuildContext context) {
    final t = context.appTokens;
    final tier = (confidenceTier ?? '').trim().toLowerCase();
    if (tier == 'high') return t.success;
    if (tier == 'medium') return t.warning;
    if (tier == 'low') return t.error;
    final c = (confidence ?? 0.5).clamp(0.0, 1.0);
    if (c >= 0.8) return t.success;
    if (c >= 0.6) return t.warning;
    return t.error;
  }

  String _priorityLabel() {
    final p = (priorityLevel ?? '').trim().toLowerCase();
    if (p == 'high') return '优先关注';
    if (p == 'medium') return '建议关注';
    return '常规关注';
  }

  Color _priorityColor(BuildContext context) {
    final t = context.appTokens;
    final p = (priorityLevel ?? '').trim().toLowerCase();
    if (p == 'high') return t.error;
    if (p == 'medium') return t.warning;
    return t.info;
  }

  String _evidenceStrengthLabel() {
    final v = (evidenceStrength ?? '').trim().toLowerCase();
    if (v == 'high') return '证据强';
    if (v == 'medium') return '证据中';
    return '证据弱';
  }

  Color _evidenceStrengthColor(BuildContext context) {
    final t = context.appTokens;
    final v = (evidenceStrength ?? '').trim().toLowerCase();
    if (v == 'high') return t.success;
    if (v == 'medium') return t.warning;
    return t.error;
  }

  bool _isCoreTag(String tag) {
    const coreKeys = <String>[
      '六合',
      '三合',
      '相冲',
      '相刑',
      '相害',
      '五行',
      '八字',
      '合盘',
      '星盘',
      '日月',
      '上升',
      'MBTI',
    ];
    return coreKeys.any((k) => tag.contains(k));
  }

  String _resolveTagExplain(String tag) {
    final fromCore = coreTagExplains[tag];
    if (fromCore != null && fromCore.trim().isNotEmpty) return fromCore.trim();
    final fromAux = auxTagExplains[tag];
    if (fromAux != null && fromAux.trim().isNotEmpty) return fromAux.trim();
    final direct = glossary[tag];
    if (direct != null && direct.trim().isNotEmpty) return direct.trim();
    for (final entry in glossary.entries) {
      if (tag.contains(entry.key) || entry.key.contains(tag)) {
        final v = entry.value.trim();
        if (v.isNotEmpty) return v;
      }
    }
    return '该标签用于标注当前结论依据的信号来源，可结合模块解释与风险提示综合判断。';
  }

  String _resolveTagRef(String tag) {
    final fromCore = coreTagRefs[tag];
    if (fromCore != null && fromCore.trim().isNotEmpty) return fromCore.trim();
    final fromAux = auxTagRefs[tag];
    if (fromAux != null && fromAux.trim().isNotEmpty) return fromAux.trim();
    return '';
  }

  void _showTagExplain(BuildContext context, String tag) {
    final t = context.appTokens;
    final explain = _resolveTagExplain(tag);
    final ref = _resolveTagRef(tag);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: t.browseSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(t.radius.lg)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            t.spacing.cardPadding,
            t.spacing.cardPadding,
            t.spacing.cardPadding,
            t.spacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                tag,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                  color: t.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: t.spacing.xs),
              Text(
                explain,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
              if (ref.isNotEmpty) ...[
                SizedBox(height: t.spacing.xs),
                Text(
                  '理论依据：$ref',
                  style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary.withValues(alpha: 0.9),
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final scoreColor = _scoreColor(context);
    final hasRisk = (risk ?? '').trim().isNotEmpty;
    final riskColor = _riskColor(context);
    final confidenceColor = _confidenceColor(context);
    final priorityColor = _priorityColor(context);
    final evidenceColor = _evidenceStrengthColor(context);
    return GestureDetector(
      onLongPress: showDebugMeta && (debugCopyText ?? '').trim().isNotEmpty
          ? () async {
              final text = (debugCopyText ?? '').trim();
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('已复制模块调试信息')));
              }
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        margin: const EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(t.spacing.cardPadding),
        decoration: BoxDecoration(
          color: highlighted ? t.info.withValues(alpha: 0.12) : t.browseSurface,
          borderRadius: BorderRadius.circular(t.radius.md),
          border: Border.all(
            color: highlighted
                ? t.info.withValues(alpha: 0.72)
                : (hasRisk
                      ? riskColor.withValues(alpha: 0.42)
                      : t.browseBorder),
            width: highlighted ? 1.6 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.auto_graph_rounded,
                  size: 15,
                  color: scoreColor.withValues(alpha: 0.9),
                ),
                SizedBox(width: t.spacing.xxs),
                Expanded(
                  child: Text(
                    module,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (showDebugMeta && (debugCopyText ?? '').trim().isNotEmpty)
                  IconButton(
                    onPressed: () async {
                      final text = (debugCopyText ?? '').trim();
                      await Clipboard.setData(ClipboardData(text: text));
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('已复制模块调试信息')),
                        );
                      }
                    },
                    tooltip: '复制模块调试信息',
                    iconSize: 18,
                    splashRadius: 18,
                    icon: Icon(Icons.copy_rounded, color: t.textSecondary),
                  ),
              ],
            ),
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: scoreColor.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    '$score分',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: evidenceColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: evidenceColor.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Text(
                    _evidenceStrengthLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: evidenceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (hasRisk)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.xs,
                      vertical: t.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(t.radius.pill),
                      border: Border.all(
                        color: riskColor.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      _riskLabel(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: riskColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: priorityColor.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Text(
                    '${_priorityLabel()}${(priorityRank ?? 0) > 0 ? " TOP$priorityRank" : ""}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: priorityColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacing.xs,
                    vertical: t.spacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: confidenceColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radius.pill),
                    border: Border.all(
                      color: confidenceColor.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Text(
                    _confidenceLabel(),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: confidenceColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (degraded)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: t.spacing.xs,
                      vertical: t.spacing.xxs,
                    ),
                    decoration: BoxDecoration(
                      color: t.info.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(t.radius.pill),
                      border: Border.all(color: t.info.withValues(alpha: 0.32)),
                    ),
                    child: Text(
                      '估算中',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: t.info,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
            if ((priorityReason ?? '').trim().isNotEmpty) ...[
              SizedBox(height: t.spacing.xs),
              Text(
                '关注原因：${priorityReason!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if ((evidenceStrengthReason ?? '').trim().isNotEmpty) ...[
              SizedBox(height: t.spacing.xxs),
              Text(
                '证据说明：${evidenceStrengthReason!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (showDebugMeta) ...[
              SizedBox(height: t.spacing.xs),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.xs,
                  vertical: t.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: t.secondarySurface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(t.radius.sm),
                  border: Border.all(
                    color: t.browseBorder.withValues(alpha: 0.45),
                  ),
                ),
                child: Text(
                  'debug: p=${priority ?? -1}, level=${(priorityLevel ?? "-").toLowerCase()}, conf=${((confidence ?? 0.5) * 100).toStringAsFixed(0)}%, degraded=${degraded ? "1" : "0"}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: t.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (degraded && (degradeReason ?? '').trim().isNotEmpty) ...[
              SizedBox(height: t.spacing.xs),
              Text(
                '降级原因：${degradeReason!.trim()}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.info,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            SizedBox(height: t.spacing.xs),
            Text(
              reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.45,
              ),
            ),
            if ((risk ?? '').trim().isNotEmpty) ...[
              SizedBox(height: t.spacing.xs),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.xs,
                  vertical: t.spacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(t.radius.sm),
                  border: Border.all(color: riskColor.withValues(alpha: 0.28)),
                ),
                child: Text(
                  '风险提示：${risk!.trim()}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: riskColor,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            if (tags.isNotEmpty ||
                coreTags.isNotEmpty ||
                auxTags.isNotEmpty) ...[
              SizedBox(height: t.spacing.xs),
              Builder(
                builder: (context) {
                  final resolvedCoreTags = coreTags.isNotEmpty
                      ? coreTags
                      : tags.where(_isCoreTag).toList();
                  final resolvedAuxTags = auxTags.isNotEmpty
                      ? auxTags
                      : tags
                            .where((e) => !resolvedCoreTags.contains(e))
                            .toList();
                  Widget tagWrap(List<String> source) {
                    return Wrap(
                      spacing: t.spacing.xs,
                      runSpacing: t.spacing.xs,
                      children: source
                          .map(
                            (tag) => InkWell(
                              borderRadius: BorderRadius.circular(
                                t.radius.pill,
                              ),
                              onTap: () => _showTagExplain(context, tag),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: t.spacing.xs,
                                  vertical: t.spacing.xxs,
                                ),
                                decoration: BoxDecoration(
                                  color: (hasRisk ? riskColor : t.browseChip)
                                      .withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(
                                    t.radius.pill,
                                  ),
                                  border: Border.all(
                                    color:
                                        (hasRisk ? riskColor : t.browseBorder)
                                            .withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Text(
                                  tag,
                                  style: Theme.of(context).textTheme.labelSmall
                                      ?.copyWith(
                                        color: t.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (resolvedCoreTags.isNotEmpty) ...[
                        Text(
                          '核心证据',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        tagWrap(resolvedCoreTags),
                      ],
                      if (resolvedAuxTags.isNotEmpty) ...[
                        SizedBox(height: t.spacing.xs),
                        Text(
                          '辅助证据',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: t.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        SizedBox(height: t.spacing.xxs),
                        tagWrap(resolvedAuxTags),
                      ],
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
