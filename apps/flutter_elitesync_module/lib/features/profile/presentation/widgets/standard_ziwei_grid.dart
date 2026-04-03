import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class StandardZiweiGrid extends StatelessWidget {
  const StandardZiweiGrid({
    super.key,
    required this.palaces,
    required this.lifePalace,
    required this.bodyPalace,
    required this.bazi,
    this.onPalaceTap,
  });

  final List<dynamic> palaces;
  final String lifePalace;
  final String bodyPalace;
  final String bazi;
  final ValueChanged<Map<String, dynamic>>? onPalaceTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final sortedPalaces = _sortedPalaces(palaces);
    final gridSlots = _gridSlots(sortedPalaces);

    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = constraints.maxWidth;
        final cellExtent = extent / 4;
        final gridHeight = extent * 1.18;
        return SizedBox(
          width: double.infinity,
          height: gridHeight,
          child: Stack(
            children: [
              Column(
                children: List.generate(4, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(4, (col) {
                        final palace = gridSlots[row][col];
                        if (palace == null) {
                          return const Expanded(child: SizedBox.expand());
                        }
                        final index = _palaceIndex(palace);
                        final name = astroText(palace['name'], '-');
                        final mainStar = astroText(palace['main_star'], '-');
                        final summaryText = astroText(
                          palace['summary'],
                          '暂无摘要',
                        );
                        final secondary = astroList(palace['secondary_stars'])
                            .map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList(growable: false);
                        final auxiliary = astroList(palace['auxiliary_stars'])
                            .map((e) => e.toString())
                            .where((e) => e.trim().isNotEmpty)
                            .toList(growable: false);
                        final isLife = name == lifePalace;
                        final isBody = name == bodyPalace;
                        final highlight = isLife || isBody;
                        final highlightColor = t.brandPrimary;
                        final background = highlight
                            ? highlightColor.withValues(
                                alpha: isLife ? 0.12 : 0.07,
                              )
                            : t.browseSurface.withValues(alpha: 0.88);

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(0.6),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleTap(
                                  context,
                                  palace,
                                  highlight,
                                  isLife,
                                  isBody,
                                ),
                                child: Container(
                                  padding: EdgeInsets.all(t.spacing.xxs),
                                  decoration: BoxDecoration(color: background),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          _TinyBadge(
                                            label: '$index宫',
                                            color: highlight
                                                ? highlightColor
                                                : t.textSecondary,
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: t.textPrimary,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 11.2,
                                            ),
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      Text(
                                        '主星 $mainStar',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: t.textSecondary,
                                              height: 1.0,
                                              fontSize: 8.4,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      SizedBox(height: t.spacing.xxs),
                                      if (secondary.isNotEmpty)
                                        Text(
                                          '辅 ${secondary.join(' / ')}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.brandPrimary
                                                    .withValues(alpha: 0.90),
                                                height: 1.0,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      if (secondary.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      if (auxiliary.isNotEmpty)
                                        Text(
                                          '杂 ${auxiliary.join(' / ')}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textSecondary,
                                                height: 1.0,
                                                fontSize: 8,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      if (auxiliary.isNotEmpty)
                                        SizedBox(height: t.spacing.xxs),
                                      Expanded(
                                        child: Text(
                                          summaryText,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: t.textPrimary,
                                                height: 1.0,
                                                fontSize: 8.1,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Padding(
                    padding: EdgeInsets.all(cellExtent),
                    child: _CenterPanel(
                      lifePalace: lifePalace,
                      bodyPalace: bodyPalace,
                      bazi: bazi,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleTap(
    BuildContext context,
    Map<String, dynamic> palace,
    bool highlight,
    bool isLife,
    bool isBody,
  ) {
    final cb = onPalaceTap;
    if (cb != null) {
      cb(palace);
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final t = sheetContext.appTokens;
        final name = astroText(palace['name'], '-');
        final mainStar = astroText(palace['main_star'], '-');
        final secondary = astroList(palace['secondary_stars'])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);
        final auxiliary = astroList(palace['auxiliary_stars'])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);
        final summaryText = astroText(palace['summary'], '暂无摘要');
        final index = _palaceIndex(palace);

        return Container(
          margin: EdgeInsets.only(
            left: t.spacing.sm,
            right: t.spacing.sm,
            bottom: t.spacing.sm,
          ),
          padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.xl),
            border: Border.all(
              color: highlight ? t.brandPrimary : t.browseBorder,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        '$name · $index宫',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (highlight)
                      Text(
                        isLife ? '命宫' : '身宫',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: t.brandPrimary.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: t.spacing.sm),
                Text(
                  '主星：$mainStar',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.spacing.sm),
                Text(
                  summaryText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    height: 1.45,
                  ),
                ),
                if (secondary.isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '辅星 / 六吉',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    secondary.join(' / '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
                if (auxiliary.isNotEmpty) ...[
                  SizedBox(height: t.spacing.sm),
                  Text(
                    '杂曜 / 六煞',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: t.spacing.xxs),
                  Text(
                    auxiliary.join(' / '),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Map<String, dynamic>> _sortedPalaces(List<dynamic> raw) {
    final list = raw.whereType<Map<String, dynamic>>().toList(growable: false);
    final sorted = [...list];
    sorted.sort((a, b) => _palaceIndex(a).compareTo(_palaceIndex(b)));
    return sorted;
  }

  List<List<Map<String, dynamic>?>> _gridSlots(
    List<Map<String, dynamic>> palaces,
  ) {
    Map<String, dynamic>? pick(int index) =>
        index < palaces.length ? palaces[index] : null;
    return [
      [pick(0), pick(1), pick(2), pick(3)],
      [pick(11), null, null, pick(4)],
      [pick(10), null, null, pick(5)],
      [pick(9), pick(8), pick(7), pick(6)],
    ];
  }

  int _palaceIndex(Map<String, dynamic> palace) =>
      (palace['index'] as num?)?.toInt() ?? 0;
}

class _CenterPanel extends StatelessWidget {
  const _CenterPanel({
    required this.lifePalace,
    required this.bodyPalace,
    required this.bazi,
  });

  final String lifePalace;
  final String bodyPalace;
  final String bazi;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final pillars = _parseBaziPillars(bazi);
    final dayMaster = pillars.isNotEmpty && pillars.length >= 3
        ? _firstChar(pillars[2])
        : '-';
    final dayMasterElement = _elementOfGan(dayMaster);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xxs,
        vertical: t.spacing.xs,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BaziPillarsGrid(pillars: pillars),
          SizedBox(height: t.spacing.xs),
          Text(
            '日主 $dayMaster${dayMasterElement.isEmpty ? '' : '（$dayMasterElement）'}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary.withValues(alpha: 0.78),
              fontSize: 8.8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BaziPillarsGrid extends StatelessWidget {
  const _BaziPillarsGrid({required this.pillars});

  final List<String> pillars;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final items = pillars.length == 4
        ? pillars
        : const ['--', '--', '--', '--'];
    const labels = ['年', '月', '日', '时'];

    return Column(
      children: [
        Row(
          children: List.generate(2, (index) {
            return Expanded(
              child: _BaziPillarCell(label: labels[index], value: items[index]),
            );
          }),
        ),
        SizedBox(height: t.spacing.xxs),
        Row(
          children: List.generate(2, (index) {
            final idx = index + 2;
            return Expanded(
              child: _BaziPillarCell(label: labels[idx], value: items[idx]),
            );
          }),
        ),
      ],
    );
  }
}

class _BaziPillarCell extends StatelessWidget {
  const _BaziPillarCell({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final stem = value.isNotEmpty ? _firstChar(value) : '-';
    final element = _elementOfGan(stem);
    final accent = _elementColor(element, t);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: t.spacing.xxs),
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xxs,
        vertical: t.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textSecondary,
              fontSize: 7.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 10.4,
            ),
          ),
        ],
      ),
    );
  }
}

List<String> _parseBaziPillars(String bazi) {
  final tokens = bazi
      .split(RegExp(r'\s+'))
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList(growable: false);
  if (tokens.length != 4) return const [];
  return tokens;
}

String _firstChar(String value) {
  if (value.isEmpty) return '-';
  final iterator = value.runes.iterator;
  if (!iterator.moveNext()) return '-';
  return String.fromCharCode(iterator.current);
}

String _elementOfGan(String stem) {
  const map = {
    '甲': '木',
    '乙': '木',
    '丙': '火',
    '丁': '火',
    '戊': '土',
    '己': '土',
    '庚': '金',
    '辛': '金',
    '壬': '水',
    '癸': '水',
  };
  return map[stem] ?? '';
}

Color _elementColor(String element, AppThemeTokens t) {
  switch (element) {
    case '木':
      return const Color(0xFF4CAF50);
    case '火':
      return const Color(0xFFF44336);
    case '土':
      return const Color(0xFF9C7B5C);
    case '金':
      return const Color(0xFF7A7E89);
    case '水':
      return const Color(0xFF2196F3);
    default:
      return t.textSecondary;
  }
}

class _TinyBadge extends StatelessWidget {
  const _TinyBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.82,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 8.3,
          height: 1.0,
        ),
      ),
    );
  }
}
