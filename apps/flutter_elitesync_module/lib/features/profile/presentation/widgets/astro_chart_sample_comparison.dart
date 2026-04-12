import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';

class AstroChartSampleSummary {
  const AstroChartSampleSummary({
    required this.sampleName,
    required this.profileName,
    required this.workbench,
    required this.visiblePointKeys,
    required this.visiblePointLabels,
    required this.visibleAspectKeys,
    required this.visibleAspectLabels,
  });

  final String sampleName;
  final String profileName;
  final AstroChartWorkbenchPrefs workbench;
  final List<String> visiblePointKeys;
  final List<String> visiblePointLabels;
  final List<String> visibleAspectKeys;
  final List<String> visibleAspectLabels;

  int get visiblePointCount => visiblePointKeys.length;
  int get visibleAspectCount => visibleAspectKeys.length;

  String get workbenchLabel =>
      '黄道=${_zodiacModeLabel(workbench.zodiacMode)} / 宫位=${_houseSystemLabel(workbench.houseSystem)} / '
      '相位=${_aspectModeLabel(workbench.aspectMode)} / 容许度=${_orbPresetLabel(workbench.orbPreset)} / '
      '点位=${_pointModeLabel(workbench.pointMode)}';

  List<String> toMarkdownLines() => [
    '- 样例：$sampleName / $profileName',
    '- 工作台：$workbenchLabel',
    '- 可见点位：$visiblePointCount',
    '- 可见相位：$visibleAspectCount',
    '- 点位清单：${visiblePointLabels.join('，')}',
    '- 相位清单：${visibleAspectLabels.join('，')}',
  ];
}

class AstroChartSampleComparisonDelta {
  const AstroChartSampleComparisonDelta({
    required this.base,
    required this.compare,
    required this.pointDelta,
    required this.aspectDelta,
    required this.addedPointLabels,
    required this.removedPointLabels,
    required this.addedAspectLabels,
    required this.removedAspectLabels,
  });

  final AstroChartSampleSummary base;
  final AstroChartSampleSummary compare;
  final int pointDelta;
  final int aspectDelta;
  final List<String> addedPointLabels;
  final List<String> removedPointLabels;
  final List<String> addedAspectLabels;
  final List<String> removedAspectLabels;

  List<String> toMarkdownLines() => [
    '- 基准：${base.sampleName} / ${base.workbenchLabel}',
    '- 对照：${compare.sampleName} / ${compare.workbenchLabel}',
    '- 点位差异：${_signed(pointDelta)}',
    '- 相位差异：${_signed(aspectDelta)}',
    if (addedPointLabels.isNotEmpty) '- 新增点位：${addedPointLabels.join('，')}',
    if (removedPointLabels.isNotEmpty) '- 移除点位：${removedPointLabels.join('，')}',
    if (addedAspectLabels.isNotEmpty) '- 新增相位：${addedAspectLabels.join('，')}',
    if (removedAspectLabels.isNotEmpty)
      '- 移除相位：${removedAspectLabels.join('，')}',
  ];
}

AstroChartSampleSummary summarizeAstroChartSample(
  Map<String, dynamic> profile, {
  required AstroChartWorkbenchPrefs workbench,
  String sampleName = '固定样例',
}) {
  final chartData = _map(profile['chart_data']);
  final source = chartData.isNotEmpty ? chartData : profile;
  final subject = _map(source['subject']);
  if (subject.isEmpty) {
    return AstroChartSampleSummary(
      sampleName: sampleName,
      profileName: '未命名样例',
      workbench: workbench,
      visiblePointKeys: const [],
      visiblePointLabels: const [],
      visibleAspectKeys: const [],
      visibleAspectLabels: const [],
    );
  }

  final points = _extractPoints(subject, workbench);
  final pointLookup = <String, _ChartPoint>{
    for (final point in points) point.name: point,
  };
  final aspects = _extractAspects(source, pointLookup, workbench);

  return AstroChartSampleSummary(
    sampleName: sampleName,
    profileName: subject['name']?.toString() ?? '未命名样例',
    workbench: workbench,
    visiblePointKeys: points.map((point) => point.key).toList(growable: false),
    visiblePointLabels: points
        .map((point) => '${point.key}(${point.label})')
        .toList(growable: false),
    visibleAspectKeys: aspects
        .map((aspect) => '${aspect.p1Name}-${aspect.p2Name} ${aspect.name}')
        .toList(growable: false),
    visibleAspectLabels: aspects
        .map(
          (aspect) =>
              '${_shortLabel(pointLookup, aspect.p1Name)}-${_shortLabel(pointLookup, aspect.p2Name)} ${aspect.name}',
        )
        .toList(growable: false),
  );
}

AstroChartSampleComparisonDelta compareAstroChartSampleSummaries(
  AstroChartSampleSummary base,
  AstroChartSampleSummary compare,
) {
  final basePointSet = base.visiblePointLabels.toSet();
  final comparePointSet = compare.visiblePointLabels.toSet();
  final baseAspectSet = base.visibleAspectLabels.toSet();
  final compareAspectSet = compare.visibleAspectLabels.toSet();

  return AstroChartSampleComparisonDelta(
    base: base,
    compare: compare,
    pointDelta: compare.visiblePointCount - base.visiblePointCount,
    aspectDelta: compare.visibleAspectCount - base.visibleAspectCount,
    addedPointLabels: compare.visiblePointLabels
        .where((label) => !basePointSet.contains(label))
        .toList(growable: false),
    removedPointLabels: base.visiblePointLabels
        .where((label) => !comparePointSet.contains(label))
        .toList(growable: false),
    addedAspectLabels: compare.visibleAspectLabels
        .where((label) => !baseAspectSet.contains(label))
        .toList(growable: false),
    removedAspectLabels: base.visibleAspectLabels
        .where((label) => !compareAspectSet.contains(label))
        .toList(growable: false),
  );
}

List<_ChartPoint> _extractPoints(
  Map<String, dynamic> subject,
  AstroChartWorkbenchPrefs workbench,
) {
  const specs = [
    ('sun', '日', '#F6C94C', AstroPointMode.core),
    ('moon', '月', '#E7ECFF', AstroPointMode.core),
    ('mercury', '水', '#8AD8FF', AstroPointMode.core),
    ('venus', '金', '#F6A6D0', AstroPointMode.core),
    ('mars', '火', '#FF8B7A', AstroPointMode.core),
    ('jupiter', '木', '#9BE38A', AstroPointMode.core),
    ('saturn', '土', '#D9C49A', AstroPointMode.core),
    ('ascendant', '升', '#FFB870', AstroPointMode.core),
    ('descendant', '降', '#FF9E9E', AstroPointMode.core),
    ('medium_coeli', '顶', '#A8D8FF', AstroPointMode.core),
    ('imum_coeli', '底', '#A8D8FF', AstroPointMode.core),
    ('uranus', '天', '#70E1C8', AstroPointMode.extended),
    ('neptune', '海', '#7EB3FF', AstroPointMode.extended),
    ('pluto', '冥', '#C69BFF', AstroPointMode.extended),
    ('chiron', '凯', '#BFD3FF', AstroPointMode.extended),
    ('mean_north_lunar_node', '北', '#86E0A9', AstroPointMode.extended),
    ('true_north_lunar_node', '北', '#86E0A9', AstroPointMode.extended),
    ('mean_south_lunar_node', '南', '#F8A3A3', AstroPointMode.extended),
    ('true_south_lunar_node', '南', '#F8A3A3', AstroPointMode.extended),
    ('earth', '地', '#B6B6B6', AstroPointMode.full),
  ];

  final result = <_ChartPoint>[];
  for (final spec in specs) {
    if (!_pointModeAllows(spec.$4, workbench.pointMode)) {
      continue;
    }
    final raw = _map(subject[spec.$1]);
    final absPos = _toDouble(raw['abs_pos']);
    if (absPos == null) continue;
    final rawName = raw['name']?.toString() ?? '';
    final name = rawName.trim().isNotEmpty ? rawName.trim() : spec.$1;
    result.add(
      _ChartPoint(
        key: spec.$1,
        name: name,
        label: spec.$2,
        absPos: absPos,
        color: spec.$3,
      ),
    );
  }
  result.sort((a, b) => a.absPos.compareTo(b.absPos));
  return result;
}

List<_AspectLine> _extractAspects(
  Map<String, dynamic> chartData,
  Map<String, _ChartPoint> pointLookup,
  AstroChartWorkbenchPrefs workbench,
) {
  final raw = chartData['aspects'];
  if (raw is! List) return const [];
  final rows = raw.whereType<Map>().map((row) => _map(row)).where((row) {
    final p1 = row['p1_name']?.toString() ?? '';
    final p2 = row['p2_name']?.toString() ?? '';
    if (!pointLookup.containsKey(p1) || !pointLookup.containsKey(p2)) {
      return false;
    }
    final aspectName = row['aspect']?.toString() ?? '';
    final orbit = _toDouble(row['orbit']) ?? 999.0;
    return _aspectModeAllows(aspectName, workbench.aspectMode) &&
        _aspectOrbitAllows(orbit, workbench.orbPreset);
  }).toList();

  final aspects = rows
      .take(24)
      .map((row) {
        final name = row['aspect']?.toString() ?? '';
        final orbit = _toDouble(row['orbit']) ?? 999.0;
        return _AspectLine(
          p1Name: row['p1_name']?.toString() ?? '',
          p2Name: row['p2_name']?.toString() ?? '',
          name: name,
          orbit: orbit,
          priority: _aspectPriority(name),
          color: _aspectColor(name),
        );
      })
      .toList(growable: false);

  aspects.sort((a, b) {
    final priorityDiff = b.priority.compareTo(a.priority);
    if (priorityDiff != 0) return priorityDiff;
    final orbitDiff = b.orbit.compareTo(a.orbit);
    if (orbitDiff != 0) return orbitDiff;
    return a.name.compareTo(b.name);
  });

  return aspects;
}

bool _pointModeAllows(AstroPointMode required, AstroPointMode current) {
  switch (current) {
    case AstroPointMode.core:
      return required == AstroPointMode.core;
    case AstroPointMode.extended:
      return required != AstroPointMode.full;
    case AstroPointMode.full:
      return true;
  }
}

bool _aspectModeAllows(String aspectName, AstroAspectMode mode) {
  final normalized = aspectName.toLowerCase().replaceAll(
    RegExp(r'[^a-z]+'),
    '',
  );
  const major = {'conjunction', 'opposition', 'trine', 'square', 'sextile'};
  const standard = {
    ...major,
    'quincunx',
    'semisextile',
    'semisquare',
    'sesquiquadrate',
  };
  switch (mode) {
    case AstroAspectMode.major:
      return major.contains(normalized);
    case AstroAspectMode.standard:
      return standard.contains(normalized) || major.contains(normalized);
    case AstroAspectMode.extended:
      return true;
  }
}

bool _aspectOrbitAllows(double orbit, AstroOrbPreset preset) {
  switch (preset) {
    case AstroOrbPreset.tight:
      return orbit <= 4.0;
    case AstroOrbPreset.standard:
      return orbit <= 6.5;
    case AstroOrbPreset.wide:
      return orbit <= 9.5;
  }
}

int _aspectPriority(String name) {
  switch (name.toLowerCase()) {
    case 'conjunction':
    case 'opposition':
    case 'trine':
    case 'square':
    case 'sextile':
      return 0;
    case 'quincunx':
    case 'semisextile':
    case 'semisquare':
    case 'sesquiquadrate':
      return 1;
    default:
      return 2;
  }
}

String _aspectColor(String name) {
  switch (name.toLowerCase()) {
    case 'conjunction':
      return '#D6D9E8';
    case 'opposition':
      return '#FF766C';
    case 'trine':
      return '#7BE0A0';
    case 'sextile':
      return '#6FB6FF';
    case 'square':
      return '#FFB86B';
    case 'quintile':
      return '#C38BFF';
    default:
      return '#9FB4FF';
  }
}

String _shortLabel(Map<String, _ChartPoint> pointLookup, String key) {
  final point = pointLookup[key];
  if (point == null) return key;
  return '${point.key}(${point.label})';
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString());
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

String _signed(int value) => value > 0 ? '+$value' : value.toString();

class _ChartPoint {
  const _ChartPoint({
    required this.key,
    required this.name,
    required this.label,
    required this.absPos,
    required this.color,
  });

  final String key;
  final String name;
  final String label;
  final double absPos;
  final String color;
}

class _AspectLine {
  const _AspectLine({
    required this.p1Name,
    required this.p2Name,
    required this.name,
    required this.orbit,
    required this.priority,
    required this.color,
  });

  final String p1Name;
  final String p2Name;
  final String name;
  final double orbit;
  final int priority;
  final String color;
}
