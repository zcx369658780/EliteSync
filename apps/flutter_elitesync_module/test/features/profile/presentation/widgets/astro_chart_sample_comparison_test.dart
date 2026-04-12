import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_comparison.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_chart_sample_fixture.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fixed sample comparison stays deterministic across presets', () {
    final standard = summarizeAstroChartSample(
      astroChartComparisonSampleProfile,
      workbench: AstroChartWorkbenchPrefs.forPreset(
        AstroChartWorkbenchPreset.standard,
      ),
      sampleName: '标准预设',
    );
    final classical = summarizeAstroChartSample(
      astroChartComparisonSampleProfile,
      workbench: AstroChartWorkbenchPrefs.forPreset(
        AstroChartWorkbenchPreset.classical,
      ),
      sampleName: '古典预设',
    );
    final modern = summarizeAstroChartSample(
      astroChartComparisonSampleProfile,
      workbench: AstroChartWorkbenchPrefs.forPreset(
        AstroChartWorkbenchPreset.modern,
      ),
      sampleName: '现代预设',
    );

    expect(classical.visiblePointCount, 11);
    expect(classical.visibleAspectCount, 4);
    expect(standard.visiblePointCount, 20);
    expect(standard.visibleAspectCount, 9);
    expect(modern.visiblePointCount, 20);
    expect(modern.visibleAspectCount, 10);
    expect(standard.visiblePointLabels, contains('sun(日)'));
    expect(standard.visiblePointLabels, contains('earth(地)'));
    expect(classical.visiblePointLabels, isNot(contains('earth(地)')));
    expect(classical.visibleAspectLabels, contains('sun(日)-moon(月) sextile'));
    expect(
      standard.visibleAspectLabels,
      contains('jupiter(木)-saturn(土) opposition'),
    );
    expect(modern.visibleAspectLabels, contains('moon(月)-pluto(冥) quintile'));

    final standardVsClassical = compareAstroChartSampleSummaries(
      classical,
      standard,
    );
    final modernVsStandard = compareAstroChartSampleSummaries(standard, modern);

    expect(standardVsClassical.pointDelta, 9);
    expect(standardVsClassical.aspectDelta, 5);
    expect(standardVsClassical.addedPointLabels, contains('uranus(天)'));
    expect(standardVsClassical.addedPointLabels, contains('earth(地)'));
    expect(
      standardVsClassical.addedAspectLabels,
      contains('jupiter(木)-saturn(土) opposition'),
    );
    expect(
      standardVsClassical.addedAspectLabels,
      contains('earth(地)-sun(日) conjunction'),
    );
    expect(modernVsStandard.pointDelta, 0);
    expect(modernVsStandard.aspectDelta, 1);
    expect(
      modernVsStandard.addedAspectLabels,
      contains('moon(月)-pluto(冥) quintile'),
    );
  });
}
