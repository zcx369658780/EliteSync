import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_parity_report.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('route parity report keeps derived-only route matrix stable', () {
    final report = buildAstroRouteParityReport(
      currentRouteMode: AstroChartRouteMode.classical,
    );

    expect(report.rows, hasLength(3));
    expect(report.standardRow.summary.visiblePointCount, 20);
    expect(report.standardRow.summary.visibleAspectCount, 9);
    expect(report.classicalRow.summary.visiblePointCount, 11);
    expect(report.classicalRow.summary.visibleAspectCount, 4);
    expect(report.modernRow.summary.visiblePointCount, 20);
    expect(report.modernRow.summary.visibleAspectCount, 10);
    expect(report.currentRow.routeMode, AstroChartRouteMode.classical);
    expect(report.currentRow.deltaLabel, '相对标准：-9 点位 / -5 相位');
    expect(
      report.toMarkdownLines(),
      contains('- 报告性质：derived-only / display-only'),
    );
    expect(report.toMarkdownLines(), contains('- 固定样例：EliteSync'));
    expect(report.toMarkdownLines(), contains('- 当前路线：古典路线'));
    expect(report.toMarkdownLines(), contains('- 标准 vs 古典：-9 点位 / -5 相位'));
    expect(report.toMarkdownLines(), contains('- 标准 vs 现代：0 点位 / +1 相位'));
  });
}
