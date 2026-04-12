import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('advanced preview requests keep derived-only scaffolds stable', () {
    final profile = <String, dynamic>{
      'name': '华严魂',
      'birthday': '1989-09-05',
      'birth_time': '14:30',
      'birth_place': '北京市海淀区人民医院',
      'birth_lat': 39.961,
      'birth_lng': 116.287,
      'tz_str': 'Asia/Shanghai',
      'nation': 'CN',
    };

    final requests = buildAstroAdvancedPreviewRequests(
      profile,
      AstroChartRouteMode.modern,
      referenceNow: DateTime(2026, 4, 12, 15, 26),
    );

    expect(requests.pair['route_mode'], 'modern');
    expect(requests.transit['route_mode'], 'modern');
    expect(requests.returnChart['route_mode'], 'modern');

    final natal = requests.pair['first'] as Map<String, dynamic>;
    final pair = requests.pair['second'] as Map<String, dynamic>;
    final transit = requests.transit['transit'] as Map<String, dynamic>;

    expect(natal['name'], '华严魂');
    expect(natal['birthday'], '1989-09-05');
    expect(pair['name'], '华严魂 对照');
    expect(pair['birthday'], '1989-09-22');
    expect(pair['birth_time'], '16:07');
    expect(transit['name'], '行运 华严魂');
    expect(transit['birthday'], '2026-04-12');
    expect(transit['birth_time'], '15:26');
    expect(requests.returnChart['return_year'], 2026);
    expect(requests.returnChart['return_type'], 'Lunar');
  });
}
