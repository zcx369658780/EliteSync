import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_route_sample_set.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'multi-route sample set keeps baseline and dense-modern samples stable',
    () {
      final report = buildAstroRouteSampleSetReport();

      expect(report.entries, hasLength(2));
      expect(report.entries.first.variant.sampleId, 'baseline');
      expect(report.entries.first.standardSummary.visiblePointCount, 20);
      expect(report.entries.first.standardSummary.visibleAspectCount, 9);
      expect(report.entries.first.classicalSummary.visiblePointCount, 11);
      expect(report.entries.first.classicalSummary.visibleAspectCount, 4);
      expect(report.entries.first.modernSummary.visiblePointCount, 20);
      expect(report.entries.first.modernSummary.visibleAspectCount, 10);

      expect(report.entries.last.variant.sampleId, 'dense-modern');
      expect(report.entries.last.standardSummary.visiblePointCount, 20);
      expect(report.entries.last.standardSummary.visibleAspectCount, 8);
      expect(report.entries.last.classicalSummary.visiblePointCount, 11);
      expect(report.entries.last.classicalSummary.visibleAspectCount, 5);
      expect(report.entries.last.modernSummary.visiblePointCount, 20);
      expect(report.entries.last.modernSummary.visibleAspectCount, 12);

      expect(report.toMarkdownLines(), contains('# 3.6 多路线样例集'));
      expect(report.toMarkdownLines(), contains('- 样例数量：2'));
      expect(report.toMarkdownLines(), contains('### 基线样例'));
      expect(report.toMarkdownLines(), contains('### 现代扩展样例'));
      expect(report.toMarkdownLines(), contains('- 说明：所有差异只用于路线解释与对照，不回写真值。'));
    },
  );
}
