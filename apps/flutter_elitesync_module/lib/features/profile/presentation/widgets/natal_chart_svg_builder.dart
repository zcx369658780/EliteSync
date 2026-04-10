import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';

String buildNatalChartSvgFromProfile(
  Map<String, dynamic> profile, {
  AstroChartDisplayPrefs? prefs,
}) {
  final chartData = _map(profile['chart_data']);
  final nestedChart = _map(_map(profile['private_natal_chart'])['chart_data']);
  final source = chartData.isNotEmpty ? chartData : nestedChart;
  if (source.isEmpty) {
    return '';
  }
  return buildNatalChartSvg(source, prefs: prefs);
}

String buildNatalChartSvg(
  Map<String, dynamic> chartData, {
  AstroChartDisplayPrefs? prefs,
}) {
  final subject = _map(chartData['subject']);
  if (subject.isEmpty) return '';

  final displayPrefs = prefs ?? AstroChartDisplayPrefs.defaults();
  final points = _extractPoints(subject);
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
    final aspects = _extractAspects(chartData, pointLookup);
    for (final aspect in aspects) {
      final p1 = pointLookup[aspect.p1Name];
      final p2 = pointLookup[aspect.p2Name];
      if (p1 == null || p2 == null) continue;
      final c1 = _polar(cx, cy, aspectRadius, _angleRad(p1.absPos));
      final c2 = _polar(cx, cy, aspectRadius, _angleRad(p2.absPos));
      final dash = _aspectDash(aspect.name);
      buffer.write(
        "<line x1='${c1.dx.toStringAsFixed(2)}' y1='${c1.dy.toStringAsFixed(2)}' x2='${c2.dx.toStringAsFixed(2)}' y2='${c2.dy.toStringAsFixed(2)}' stroke='${aspect.color}' stroke-opacity='0.58' stroke-width='1.8' stroke-dasharray='$dash' />",
      );
    }
  }

  for (var i = 0; i < points.length; i++) {
    final point = points[i];
    final angle = _angleRad(point.absPos);
    final dot = _polar(cx, cy, planetRadius, angle);
    final labelRadius = planetRadius + 30 + (i % 3) * 12;
    final labelAngle = angle + ((i % 2 == 0) ? -0.06 : 0.06);
    final labelPos = _polar(cx, cy, labelRadius, labelAngle);
    final textAnchor = labelPos.dx >= cx ? 'start' : 'end';
    if (displayPrefs.showChartPlanetConnectors) {
      buffer.write(
        "<line x1='${dot.dx.toStringAsFixed(2)}' y1='${dot.dy.toStringAsFixed(2)}' x2='${labelPos.dx.toStringAsFixed(2)}' y2='${labelPos.dy.toStringAsFixed(2)}' stroke='${point.color}' stroke-opacity='0.55' stroke-width='1.3' />",
      );
    }
    if (displayPrefs.showChartPlanetMarkers) {
      buffer.write(
        "<circle cx='${dot.dx.toStringAsFixed(2)}' cy='${dot.dy.toStringAsFixed(2)}' r='12.5' fill='${point.color}' stroke='rgba(255,255,255,0.92)' stroke-width='2' />",
      );
    }
    if (displayPrefs.showChartPlanetLabels) {
      buffer.write(
        "<text x='${labelPos.dx.toStringAsFixed(2)}' y='${labelPos.dy.toStringAsFixed(2)}' text-anchor='$textAnchor' dominant-baseline='middle' fill='white' font-size='19' font-family='PingFang SC, Noto Sans SC, sans-serif' font-weight='700'>${_esc(point.label)}</text>",
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

List<_ChartPoint> _extractPoints(Map<String, dynamic> subject) {
  const specs = [
    ('sun', '日', '#F6C94C'),
    ('moon', '月', '#E7ECFF'),
    ('mercury', '水', '#8AD8FF'),
    ('venus', '金', '#F6A6D0'),
    ('mars', '火', '#FF8B7A'),
    ('jupiter', '木', '#9BE38A'),
    ('saturn', '土', '#D9C49A'),
    ('uranus', '天', '#70E1C8'),
    ('neptune', '海', '#7EB3FF'),
    ('pluto', '冥', '#C69BFF'),
    ('chiron', '凯', '#BFD3FF'),
    ('ascendant', '升', '#FFB870'),
    ('descendant', '降', '#FF9E9E'),
    ('medium_coeli', '顶', '#A8D8FF'),
    ('imum_coeli', '底', '#A8D8FF'),
    ('mean_north_lunar_node', '北', '#86E0A9'),
    ('true_north_lunar_node', '北', '#86E0A9'),
    ('mean_south_lunar_node', '南', '#F8A3A3'),
    ('true_south_lunar_node', '南', '#F8A3A3'),
    ('earth', '地', '#B6B6B6'),
  ];

  final result = <_ChartPoint>[];
  for (final spec in specs) {
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
) {
  final raw = chartData['aspects'];
  if (raw is! List) return const [];
  final rows = raw.whereType<Map>().map((row) => _map(row)).where((row) {
    final p1 = row['p1_name']?.toString() ?? '';
    final p2 = row['p2_name']?.toString() ?? '';
    return pointLookup.containsKey(p1) && pointLookup.containsKey(p2);
  }).toList();

  rows.sort((a, b) {
    final oa = _toDouble(a['orbit']) ?? 999.0;
    final ob = _toDouble(b['orbit']) ?? 999.0;
    return oa.compareTo(ob);
  });

  return rows
      .take(24)
      .map((row) {
        final name = row['aspect']?.toString() ?? '';
        return _AspectLine(
          p1Name: row['p1_name']?.toString() ?? '',
          p2Name: row['p2_name']?.toString() ?? '',
          name: name,
          color: _aspectColor(name),
        );
      })
      .toList(growable: false);
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
    required this.color,
  });

  final String p1Name;
  final String p2Name;
  final String name;
  final String color;
}
