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
}
