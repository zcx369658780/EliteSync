import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_calibration_report.dart';

void main() {
  test('calibration report keeps sample calibration and deviation archive stable', () {
    final report = buildAstroCalibrationReport();
    final lines = report.toMarkdownLines();

    expect(report.sampleSet.entries, hasLength(2));
    expect(lines, contains('# 3.8 校准报告'));
    expect(lines, contains('- 报告性质：derived-only / display-only / advanced-context'));
    expect(lines, contains('- 样例数量：2'));
    expect(lines, contains('- 说明：以下差异只用于校准与归档，不回写 canonical truth。'));
    expect(lines, contains('- 已知偏差：'));
    expect(
      lines.where((line) => line.contains('baseline')).length,
      greaterThanOrEqualTo(1),
    );
    expect(
      lines.where((line) => line.contains('dense-modern')).length,
      greaterThanOrEqualTo(1),
    );
  });
}
