import 'dart:math';

import 'package:flutter_elitesync_module/features/profile/presentation/widgets/natal_chart_svg_builder.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildNatalChartSvgFromProfile renders svg from chart_data', () {
    final profile = <String, dynamic>{
      'chart_data': {
        'subject': {
          'name': 'EliteSync',
          'city': '北京市朝阳区',
          'iso_formatted_local_datetime': '1996-08-18T10:30:00+08:00',
          'sun': {'name': 'Sun', 'abs_pos': 145.43},
          'moon': {'name': 'Moon', 'abs_pos': 187.44},
          'ascendant': {'name': 'Ascendant', 'abs_pos': 204.45},
          'first_house': {'name': 'First_House', 'abs_pos': 204.45},
          'second_house': {'name': 'Second_House', 'abs_pos': 234.45},
          'seventh_house': {'name': 'Seventh_House', 'abs_pos': 24.45},
        },
        'aspects': [
          {
            'p1_name': 'Sun',
            'p2_name': 'Moon',
            'aspect': 'sextile',
            'orbit': 1.0,
          },
        ],
      },
    };

    final svg = buildNatalChartSvgFromProfile(profile);

    expect(svg, contains('<svg'));
    expect(svg, contains('EliteSync'));
    expect(svg, contains('白羊'));
    expect(svg, contains('日'));
  });

  test('buildNatalChartSvgFromProfile respects chart element prefs', () {
    final profile = <String, dynamic>{
      'chart_data': {
        'subject': {
          'name': 'EliteSync',
          'city': '北京市朝阳区',
          'iso_formatted_local_datetime': '1996-08-18T10:30:00+08:00',
          'sun': {'name': 'Sun', 'abs_pos': 145.43},
          'moon': {'name': 'Moon', 'abs_pos': 187.44},
          'ascendant': {'name': 'Ascendant', 'abs_pos': 204.45},
          'first_house': {'name': 'First_House', 'abs_pos': 204.45},
          'second_house': {'name': 'Second_House', 'abs_pos': 234.45},
          'seventh_house': {'name': 'Seventh_House', 'abs_pos': 24.45},
        },
        'aspects': [
          {
            'p1_name': 'Sun',
            'p2_name': 'Moon',
            'aspect': 'sextile',
            'orbit': 1.0,
          },
        ],
      },
    };

    final prefs = AstroChartDisplayPrefs.defaults().copyWith(
      showChartSignGridLines: false,
      showChartSignLabels: false,
      showChartHouseLines: false,
      showChartHouseNumbers: false,
      showChartAspectLines: false,
      showChartPlanetConnectors: false,
      showChartPlanetMarkers: false,
      showChartPlanetLabels: false,
      showChartCenterTitle: false,
      showChartCenterSubtitle: false,
      showChartCenterPlace: false,
    );

    final svg = buildNatalChartSvgFromProfile(profile, prefs: prefs);

    expect(svg, contains('<svg'));
    expect(svg, isNot(contains('EliteSync')));
    expect(svg, isNot(contains('白羊')));
    expect(svg, isNot(contains('日')));
    expect(svg, isNot(contains('月')));
    expect(svg, isNot(contains('升')));
    expect(svg, isNot(contains('北')));
  });

  test(
    'buildNatalChartSvgFromProfile respects workbench point and aspect filters',
    () {
      final profile = <String, dynamic>{
        'chart_data': {
          'subject': {
            'name': 'EliteSync',
            'city': '北京市朝阳区',
            'iso_formatted_local_datetime': '1996-08-18T10:30:00+08:00',
            'sun': {'name': 'Sun', 'abs_pos': 145.43},
            'moon': {'name': 'Moon', 'abs_pos': 187.44},
            'pluto': {'name': 'Pluto', 'abs_pos': 231.10},
            'earth': {'name': 'Earth', 'abs_pos': 11.10},
            'ascendant': {'name': 'Ascendant', 'abs_pos': 204.45},
            'first_house': {'name': 'First_House', 'abs_pos': 204.45},
            'second_house': {'name': 'Second_House', 'abs_pos': 234.45},
            'seventh_house': {'name': 'Seventh_House', 'abs_pos': 24.45},
          },
          'aspects': [
            {
              'p1_name': 'Sun',
              'p2_name': 'Moon',
              'aspect': 'sextile',
              'orbit': 1.0,
            },
            {
              'p1_name': 'Sun',
              'p2_name': 'Pluto',
              'aspect': 'quintile',
              'orbit': 1.0,
            },
            {
              'p1_name': 'Moon',
              'p2_name': 'Sun',
              'aspect': 'square',
              'orbit': 8.2,
            },
          ],
        },
      };

      final corePrefs = AstroChartWorkbenchPrefs.forPreset(
        AstroChartWorkbenchPreset.classical,
      );
      final fullPrefs = AstroChartWorkbenchPrefs.defaults().copyWith(
        aspectMode: AstroAspectMode.extended,
        orbPreset: AstroOrbPreset.standard,
        pointMode: AstroPointMode.full,
      );

      final coreSvg = buildNatalChartSvgFromProfile(
        profile,
        workbenchPrefs: corePrefs,
      );
      final fullSvg = buildNatalChartSvgFromProfile(
        profile,
        workbenchPrefs: fullPrefs,
      );

      expect(coreSvg, isNot(contains("fill='#C69BFF'")));
      expect(coreSvg, isNot(contains("fill='#B6B6B6'")));
      expect(fullSvg, contains("fill='#C69BFF'"));
      expect(fullSvg, contains("fill='#B6B6B6'"));
      expect(coreSvg, contains("stroke-opacity='0.72'"));
      expect(fullSvg, contains("stroke-opacity='0.72'"));
      expect(fullSvg, contains("stroke-opacity='0.48'"));
    },
  );

  test('buildNatalChartSvgFromProfile separates dense planet labels', () {
    final profile = <String, dynamic>{
      'chart_data': {
        'subject': {
          'name': 'EliteSync',
          'city': '北京市朝阳区',
          'iso_formatted_local_datetime': '1996-08-18T10:30:00+08:00',
          'sun': {'name': 'Sun', 'abs_pos': 128.0},
          'moon': {'name': 'Moon', 'abs_pos': 128.8},
          'mercury': {'name': 'Mercury', 'abs_pos': 129.2},
          'venus': {'name': 'Venus', 'abs_pos': 129.6},
          'mars': {'name': 'Mars', 'abs_pos': 130.1},
          'jupiter': {'name': 'Jupiter', 'abs_pos': 130.6},
          'saturn': {'name': 'Saturn', 'abs_pos': 131.0},
          'first_house': {'name': 'First_House', 'abs_pos': 204.45},
          'second_house': {'name': 'Second_House', 'abs_pos': 234.45},
          'seventh_house': {'name': 'Seventh_House', 'abs_pos': 24.45},
        },
        'aspects': const [],
      },
    };

    final svg = buildNatalChartSvgFromProfile(profile);
    final labels = ['日', '月', '水', '金', '火', '木', '土'];
    final positions = <String, List<double>>{};

    for (final label in labels) {
      final match = RegExp(
        r"<text x='([0-9.]+)' y='([0-9.]+)'[^>]*>" +
            RegExp.escape(label) +
            r"</text>",
      ).firstMatch(svg);
      expect(match, isNotNull, reason: 'missing label $label');
      positions[label] = [
        double.parse(match!.group(1)!),
        double.parse(match.group(2)!),
      ];
    }

    for (var i = 0; i < labels.length; i++) {
      for (var j = i + 1; j < labels.length; j++) {
        final a = positions[labels[i]]!;
        final b = positions[labels[j]]!;
        final distance = sqrt(pow(a[0] - b[0], 2) + pow(a[1] - b[1], 2));
        expect(
          distance,
          greaterThan(26.0),
          reason: 'labels ${labels[i]} and ${labels[j]} are too close',
        );
      }
    }
  });
}
