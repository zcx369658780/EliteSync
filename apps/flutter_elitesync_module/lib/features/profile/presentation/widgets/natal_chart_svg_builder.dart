import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';

String buildNatalChartSvgFromProfile(
  Map<String, dynamic> profile, {
  AstroChartDisplayPrefs? prefs,
  AstroChartWorkbenchPrefs? workbenchPrefs,
}) {
  final chartData = _map(profile['chart_data']);
  final nestedChart = _map(_map(profile['private_natal_chart'])['chart_data']);
  final source = chartData.isNotEmpty ? chartData : nestedChart;
  if (source.isEmpty) {
    return '';
  }
  return buildNatalChartSvg(
    source,
    prefs: prefs,
    workbenchPrefs: workbenchPrefs,
  );
}

String buildNatalChartSvg(
  Map<String, dynamic> chartData, {
  AstroChartDisplayPrefs? prefs,
  AstroChartWorkbenchPrefs? workbenchPrefs,
}) {
  final subject = _map(chartData['subject']);
  if (subject.isEmpty) return '';

  final displayPrefs = prefs ?? AstroChartDisplayPrefs.defaults();
  final workbench = workbenchPrefs ?? AstroChartWorkbenchPrefs.defaults();
  final points = _extractPoints(subject, workbench);
  if (points.isEmpty) return '';

  const size = 1000.0;
  const cx = size / 2;
  const cy = size / 2;
  const outerRadius = 448.0;
  const signRingOuter = 448.0;
  const signRingInner = 380.0;
  const houseRingInner = 300.0;
  const aspectRadius = 242.0;
  const planetRadius = 338.0;

  final pointLookup = <String, _ChartPoint>{};
  for (final point in points) {
    pointLookup[point.name] = point;
  }

  final buffer = StringBuffer()
    ..write(
      "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 1000 1000' role='img' aria-label='本地星盘'>",
    )
    ..write(_defs())
    ..write("<rect width='1000' height='1000' fill='url(#chartBg)' />")
    ..write(
      "<circle cx='$cx' cy='$cy' r='470' fill='url(#chartGlow)' opacity='0.65' />",
    )
    ..write(
      "<circle cx='$cx' cy='$cy' r='$outerRadius' fill='none' stroke='rgba(255,255,255,0.20)' stroke-width='2' />",
    )
    ..write(
      "<circle cx='$cx' cy='$cy' r='$signRingInner' fill='none' stroke='rgba(255,255,255,0.14)' stroke-width='2' />",
    )
    ..write(
      "<circle cx='$cx' cy='$cy' r='$houseRingInner' fill='none' stroke='rgba(255,255,255,0.12)' stroke-width='2' />",
    )
    ..write(
      "<circle cx='$cx' cy='$cy' r='180' fill='none' stroke='rgba(255,255,255,0.10)' stroke-width='2' />",
    );

  if (displayPrefs.showChartSignGridLines) {
    for (var i = 0; i < 12; i++) {
      final degree = i * 30.0;
      final angle = _angleRad(degree);
      final inner = _polar(cx, cy, signRingInner, angle);
      final outer = _polar(cx, cy, signRingOuter, angle);
      buffer.write(
        "<line x1='${inner.dx.toStringAsFixed(2)}' y1='${inner.dy.toStringAsFixed(2)}' x2='${outer.dx.toStringAsFixed(2)}' y2='${outer.dy.toStringAsFixed(2)}' stroke='rgba(255,255,255,0.12)' stroke-width='2' />",
      );
    }
  }

  if (displayPrefs.showChartSignLabels) {
    for (var i = 0; i < 12; i++) {
      final degree = i * 30.0;
      final labelPos = _polar(cx, cy, 414.0, _angleRad(degree + 15));
      final label = _zodiacLabel(i);
      buffer.write(
        "<text x='${labelPos.dx.toStringAsFixed(2)}' y='${labelPos.dy.toStringAsFixed(2)}' text-anchor='middle' dominant-baseline='middle' fill='rgba(255,255,255,0.78)' font-size='22' font-family='PingFang SC, Noto Sans SC, sans-serif' font-weight='700'>$label</text>",
      );
    }
  }

  final houses = _housePoints(subject);
  if (displayPrefs.showChartHouseLines) {
    for (final house in houses) {
      final angle = _angleRad(house.absPos);
      final inner = _polar(cx, cy, houseRingInner, angle);
      final outer = _polar(cx, cy, outerRadius, angle);
      buffer.write(
        "<line x1='${inner.dx.toStringAsFixed(2)}' y1='${inner.dy.toStringAsFixed(2)}' x2='${outer.dx.toStringAsFixed(2)}' y2='${outer.dy.toStringAsFixed(2)}' stroke='rgba(255,255,255,0.18)' stroke-width='1.5' />",
      );
    }
  }

  if (displayPrefs.showChartHouseNumbers) {
    for (final house in houses) {
      final angle = _angleRad(house.absPos);
      final labelPos = _polar(cx, cy, 270.0, angle);
      buffer.write(
        "<text x='${labelPos.dx.toStringAsFixed(2)}' y='${labelPos.dy.toStringAsFixed(2)}' text-anchor='middle' dominant-baseline='middle' fill='rgba(255,255,255,0.26)' font-size='18' font-family='PingFang SC, Noto Sans SC, sans-serif'>${house.index}</text>",
      );
    }
  }

  if (displayPrefs.showChartAspectLines) {
    final aspects = _extractAspects(chartData, pointLookup, workbench);
    for (final aspect in aspects) {
      final p1 = pointLookup[aspect.p1Name];
      final p2 = pointLookup[aspect.p2Name];
      if (p1 == null || p2 == null) continue;
      final c1 = _polar(cx, cy, aspectRadius, _angleRad(p1.absPos));
      final c2 = _polar(cx, cy, aspectRadius, _angleRad(p2.absPos));
      final dash = _aspectDash(aspect.name);
      final opacity = _aspectOpacity(aspect.name, aspect.orbit);
      final strokeWidth = _aspectStrokeWidth(aspect.name, aspect.orbit);
      buffer.write(
        "<line x1='${c1.dx.toStringAsFixed(2)}' y1='${c1.dy.toStringAsFixed(2)}' x2='${c2.dx.toStringAsFixed(2)}' y2='${c2.dy.toStringAsFixed(2)}' stroke='${aspect.color}' stroke-opacity='${opacity.toStringAsFixed(2)}' stroke-width='${strokeWidth.toStringAsFixed(2)}' stroke-dasharray='$dash' />",
      );
    }
  }

  final placements = _layoutPointLabels(
    points,
    cx: cx,
    cy: cy,
    planetRadius: planetRadius,
  );
  for (final placement in placements) {
    if (displayPrefs.showChartPlanetConnectors) {
      buffer.write(
        "<line x1='${placement.dot.dx.toStringAsFixed(2)}' y1='${placement.dot.dy.toStringAsFixed(2)}' x2='${placement.labelPos.dx.toStringAsFixed(2)}' y2='${placement.labelPos.dy.toStringAsFixed(2)}' stroke='${placement.point.color}' stroke-opacity='0.55' stroke-width='1.3' />",
      );
    }
    if (displayPrefs.showChartPlanetMarkers) {
      buffer.write(
        "<circle cx='${placement.dot.dx.toStringAsFixed(2)}' cy='${placement.dot.dy.toStringAsFixed(2)}' r='12.5' fill='${placement.point.color}' stroke='rgba(255,255,255,0.92)' stroke-width='2' />",
      );
    }
    if (displayPrefs.showChartPlanetLabels) {
      buffer.write(
        "<text x='${placement.labelPos.dx.toStringAsFixed(2)}' y='${placement.labelPos.dy.toStringAsFixed(2)}' text-anchor='${placement.textAnchor}' dominant-baseline='middle' fill='white' font-size='${placement.fontSize}' font-family='PingFang SC, Noto Sans SC, sans-serif' font-weight='700'>${_esc(placement.point.label)}</text>",
      );
    }
  }

  final titleRaw = subject['name']?.toString() ?? 'EliteSync';
  final title = _esc(titleRaw);
  final subtitleRaw = subject['iso_formatted_local_datetime']?.toString() ?? '';
  final subtitle = _esc(subtitleRaw.isNotEmpty ? subtitleRaw : '本地绘制星盘');
  final placeRaw = subject['city']?.toString() ?? '';
  final place = _esc(placeRaw);
  buffer.write(
    "<circle cx='$cx' cy='$cy' r='150' fill='rgba(10,16,36,0.96)' stroke='rgba(255,255,255,0.12)' stroke-width='2' />",
  );
  if (displayPrefs.showChartCenterTitle) {
    buffer.write(
      "<text x='$cx' y='470' text-anchor='middle' fill='rgba(255,255,255,0.94)' font-size='28' font-family='PingFang SC, Noto Sans SC, sans-serif' font-weight='800'>$title</text>",
    );
  }
  if (displayPrefs.showChartCenterSubtitle) {
    buffer.write(
      "<text x='$cx' y='510' text-anchor='middle' fill='rgba(255,255,255,0.68)' font-size='18' font-family='PingFang SC, Noto Sans SC, sans-serif'>$subtitle</text>",
    );
  }
  if (displayPrefs.showChartCenterPlace && place.isNotEmpty) {
    buffer.write(
      "<text x='$cx' y='542' text-anchor='middle' fill='rgba(255,255,255,0.56)' font-size='17' font-family='PingFang SC, Noto Sans SC, sans-serif'>$place</text>",
    );
  }
  buffer.write('</svg>');
  return buffer.toString();
}

String _defs() => '''
<defs>
  <linearGradient id="chartBg" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#071024" />
    <stop offset="55%" stop-color="#101b36" />
    <stop offset="100%" stop-color="#1e2745" />
  </linearGradient>
  <radialGradient id="chartGlow" cx="50%" cy="45%" r="55%">
    <stop offset="0%" stop-color="#3a4e8b" stop-opacity="0.55" />
    <stop offset="48%" stop-color="#162442" stop-opacity="0.28" />
    <stop offset="100%" stop-color="#071024" stop-opacity="0" />
  </radialGradient>
</defs>
''';

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

List<_HousePoint> _housePoints(Map<String, dynamic> subject) {
  const keys = [
    'first_house',
    'second_house',
    'third_house',
    'fourth_house',
    'fifth_house',
    'sixth_house',
    'seventh_house',
    'eighth_house',
    'ninth_house',
    'tenth_house',
    'eleventh_house',
    'twelfth_house',
  ];
  final result = <_HousePoint>[];
  for (var i = 0; i < keys.length; i++) {
    final raw = _map(subject[keys[i]]);
    final absPos = _toDouble(raw['abs_pos']) ?? _toDouble(raw['position']);
    if (absPos == null) continue;
    result.add(_HousePoint(index: i + 1, absPos: absPos));
  }
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

double _aspectOpacity(String name, double orbit) {
  final priority = _aspectPriority(name);
  final base = switch (priority) {
    0 => 0.74,
    1 => 0.62,
    _ => 0.50,
  };
  final orbitPenalty = (orbit.clamp(0.0, 12.0) / 12.0) * 0.18;
  return (base - orbitPenalty).clamp(0.28, 0.78).toDouble();
}

double _aspectStrokeWidth(String name, double orbit) {
  final priority = _aspectPriority(name);
  final base = switch (priority) {
    0 => 2.05,
    1 => 1.75,
    _ => 1.45,
  };
  final orbitBonus = orbit <= 3.0
      ? 0.14
      : orbit >= 8.0
      ? -0.08
      : 0.0;
  return (base + orbitBonus).clamp(1.25, 2.25).toDouble();
}

String _aspectDash(String name) {
  switch (name.toLowerCase()) {
    case 'opposition':
      return '8 8';
    case 'square':
      return '6 7';
    case 'trine':
      return '10 6';
    case 'sextile':
      return '9 7';
    case 'conjunction':
      return '4 5';
    default:
      return '7 7';
  }
}

double _labelLaneOffset(String key, double absPos) {
  final sector = ((absPos % 360) / 30).floor();
  final base = switch (key.toLowerCase()) {
    'sun' || 'moon' => 78.0,
    'mercury' || 'venus' || 'mars' => 94.0,
    'jupiter' || 'saturn' => 112.0,
    'uranus' || 'neptune' || 'pluto' => 128.0,
    'ascendant' || 'descendant' || 'medium_coeli' || 'imum_coeli' => 132.0,
    'mean_north_lunar_node' ||
    'true_north_lunar_node' ||
    'mean_south_lunar_node' ||
    'true_south_lunar_node' => 120.0,
    _ => 100.0,
  };
  final sectorBias = switch (sector % 4) {
    0 => 0.0,
    1 => 12.0,
    2 => -8.0,
    _ => 6.0,
  };
  return base + sectorBias;
}

double _labelLift(String key) {
  return switch (key.toLowerCase()) {
    'sun' || 'moon' => 0.055,
    'mercury' || 'venus' || 'mars' => 0.060,
    'jupiter' || 'saturn' => 0.064,
    'uranus' || 'neptune' || 'pluto' => 0.070,
    'ascendant' || 'descendant' || 'medium_coeli' || 'imum_coeli' => 0.060,
    _ => 0.058,
  };
}

List<_PointLabelPlacement> _layoutPointLabels(
  List<_ChartPoint> points, {
  required double cx,
  required double cy,
  required double planetRadius,
}) {
  final ordered = [...points]
    ..sort((a, b) {
      final pa = _pointPriority(a.key);
      final pb = _pointPriority(b.key);
      if (pa != pb) return pa.compareTo(pb);
      final absPosDiff = a.absPos.compareTo(b.absPos);
      if (absPosDiff != 0) return absPosDiff;
      return a.key.compareTo(b.key);
    });

  final placements = <_PointLabelPlacement>[];
  for (var i = 0; i < ordered.length; i++) {
    final point = ordered[i];
    final angle = _angleRad(point.absPos);
    final dot = _polar(cx, cy, planetRadius, angle);
    final laneOffset = _labelLaneOffset(point.key, point.absPos);
    final labelLift = _labelLift(point.key);
    final fontSize = _labelFontSize(point.key);
    final baseRadius = planetRadius + laneOffset;
    final parityDirection = i.isEven ? -1.0 : 1.0;
    final sideDirection = dot.dx >= cx ? 1.0 : -1.0;

    var chosen = _PointLabelPlacement(
      point: point,
      dot: dot,
      labelPos: _polar(
        cx,
        cy,
        baseRadius,
        angle + (parityDirection * labelLift),
      ),
      textAnchor: dot.dx >= cx ? 'start' : 'end',
      fontSize: fontSize,
    );
    for (var attempt = 0; attempt < 6; attempt++) {
      final radius = baseRadius + (attempt * 14.0);
      final angleJitter = attempt == 0 ? 0.0 : 0.014 * attempt * sideDirection;
      final liftJitter = labelLift + (attempt * 0.0025);
      final candidateAngle =
          angle + (parityDirection * liftJitter) + angleJitter;
      final candidate = _PointLabelPlacement(
        point: point,
        dot: dot,
        labelPos: _polar(cx, cy, radius, candidateAngle),
        textAnchor: _polar(cx, cy, radius, candidateAngle).dx >= cx
            ? 'start'
            : 'end',
        fontSize: fontSize,
      );
      chosen = candidate;
      if (!_labelOverlaps(candidate, placements)) {
        break;
      }
    }
    placements.add(chosen);
  }
  return placements;
}

bool _labelOverlaps(
  _PointLabelPlacement candidate,
  List<_PointLabelPlacement> placements,
) {
  final threshold = (candidate.fontSize * 1.45).clamp(32.0, 48.0).toDouble();
  for (final existing in placements) {
    final distance = (candidate.labelPos - existing.labelPos).distance;
    if (distance < threshold) {
      return true;
    }
  }
  return false;
}

int _pointPriority(String key) {
  switch (key.toLowerCase()) {
    case 'sun':
    case 'moon':
    case 'mercury':
    case 'venus':
    case 'mars':
    case 'jupiter':
    case 'saturn':
    case 'ascendant':
    case 'descendant':
    case 'medium_coeli':
    case 'imum_coeli':
      return 0;
    case 'uranus':
    case 'neptune':
    case 'pluto':
    case 'chiron':
    case 'mean_north_lunar_node':
    case 'true_north_lunar_node':
    case 'mean_south_lunar_node':
    case 'true_south_lunar_node':
      return 1;
    default:
      return 2;
  }
}

double _labelFontSize(String key) {
  return switch (key.toLowerCase()) {
    'sun' || 'moon' => 19,
    'mercury' || 'venus' || 'mars' => 18,
    'jupiter' || 'saturn' => 17,
    'uranus' || 'neptune' || 'pluto' => 17,
    'ascendant' || 'descendant' || 'medium_coeli' || 'imum_coeli' => 16,
    'mean_north_lunar_node' ||
    'true_north_lunar_node' ||
    'mean_south_lunar_node' ||
    'true_south_lunar_node' => 16,
    _ => 17,
  };
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

String _zodiacLabel(int index) {
  const labels = [
    '白羊',
    '金牛',
    '双子',
    '巨蟹',
    '狮子',
    '处女',
    '天秤',
    '天蝎',
    '射手',
    '摩羯',
    '水瓶',
    '双鱼',
  ];
  return labels[index % labels.length];
}

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

double? _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString());
}

Offset _polar(double cx, double cy, double radius, double angle) {
  return Offset(cx + radius * cos(angle), cy + radius * sin(angle));
}

double _angleRad(double degrees) => (degrees - 90.0) * pi / 180.0;

String _esc(String input) => const HtmlEscape().convert(input);

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

class _HousePoint {
  const _HousePoint({required this.index, required this.absPos});

  final int index;
  final double absPos;
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

class _PointLabelPlacement {
  const _PointLabelPlacement({
    required this.point,
    required this.dot,
    required this.labelPos,
    required this.textAnchor,
    required this.fontSize,
  });

  final _ChartPoint point;
  final Offset dot;
  final Offset labelPos;
  final String textAnchor;
  final double fontSize;
}
