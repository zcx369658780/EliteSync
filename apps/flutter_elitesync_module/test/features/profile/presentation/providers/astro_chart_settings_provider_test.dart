import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AstroChartDisplayPrefs defaults keep chart element toggles on', () {
    final prefs = AstroChartDisplayPrefs.defaults();

    expect(prefs.showPlanetSummary, isTrue);
    expect(prefs.showHouseSummary, isTrue);
    expect(prefs.showAspectSummary, isTrue);
    expect(prefs.showTechnicalParameters, isTrue);
    expect(prefs.compactDensity, isFalse);
    expect(prefs.showChartSignGridLines, isTrue);
    expect(prefs.showChartSignLabels, isTrue);
    expect(prefs.showChartHouseLines, isTrue);
    expect(prefs.showChartHouseNumbers, isTrue);
    expect(prefs.showChartAspectLines, isTrue);
    expect(prefs.showChartPlanetConnectors, isTrue);
    expect(prefs.showChartPlanetMarkers, isTrue);
    expect(prefs.showChartPlanetLabels, isTrue);
    expect(prefs.showChartCenterTitle, isTrue);
    expect(prefs.showChartCenterSubtitle, isTrue);
    expect(prefs.showChartCenterPlace, isTrue);
  });

  test('AstroChartDisplayPrefs.fromJson keeps old caches compatible', () {
    final prefs = AstroChartDisplayPrefs.fromJson(const {
      'showPlanetSummary': false,
      'showHouseSummary': true,
      'showAspectSummary': false,
      'showTechnicalParameters': true,
      'compactDensity': true,
    });

    expect(prefs.showPlanetSummary, isFalse);
    expect(prefs.showHouseSummary, isTrue);
    expect(prefs.showAspectSummary, isFalse);
    expect(prefs.showTechnicalParameters, isTrue);
    expect(prefs.compactDensity, isTrue);
    expect(prefs.showChartSignGridLines, isTrue);
    expect(prefs.showChartSignLabels, isTrue);
    expect(prefs.showChartHouseLines, isTrue);
    expect(prefs.showChartHouseNumbers, isTrue);
    expect(prefs.showChartAspectLines, isTrue);
    expect(prefs.showChartPlanetConnectors, isTrue);
    expect(prefs.showChartPlanetMarkers, isTrue);
    expect(prefs.showChartPlanetLabels, isTrue);
    expect(prefs.showChartCenterTitle, isTrue);
    expect(prefs.showChartCenterSubtitle, isTrue);
    expect(prefs.showChartCenterPlace, isTrue);
  });

  test(
    'AstroChartDisplayPrefs.forPreset provides balanced and minimal variants',
    () {
      final balanced = AstroChartDisplayPrefs.forPreset(
        AstroChartDisplayPreset.balanced,
      );
      final minimal = AstroChartDisplayPrefs.forPreset(
        AstroChartDisplayPreset.minimal,
      );

      expect(balanced.compactDensity, isTrue);
      expect(balanced.showChartSignGridLines, isFalse);
      expect(balanced.showChartSignLabels, isTrue);
      expect(balanced.showChartHouseLines, isTrue);
      expect(balanced.showChartHouseNumbers, isFalse);
      expect(balanced.showChartAspectLines, isTrue);
      expect(balanced.showChartPlanetConnectors, isFalse);
      expect(balanced.showChartPlanetMarkers, isTrue);
      expect(balanced.showChartPlanetLabels, isTrue);
      expect(balanced.showChartCenterTitle, isTrue);
      expect(balanced.showChartCenterSubtitle, isFalse);
      expect(balanced.showChartCenterPlace, isFalse);

      expect(minimal.showPlanetSummary, isFalse);
      expect(minimal.showHouseSummary, isFalse);
      expect(minimal.showAspectSummary, isFalse);
      expect(minimal.showTechnicalParameters, isFalse);
      expect(minimal.compactDensity, isTrue);
      expect(minimal.showChartSignGridLines, isFalse);
      expect(minimal.showChartSignLabels, isFalse);
      expect(minimal.showChartHouseLines, isTrue);
      expect(minimal.showChartHouseNumbers, isFalse);
      expect(minimal.showChartAspectLines, isFalse);
      expect(minimal.showChartPlanetConnectors, isFalse);
      expect(minimal.showChartPlanetMarkers, isTrue);
      expect(minimal.showChartPlanetLabels, isTrue);
      expect(minimal.showChartCenterTitle, isTrue);
      expect(minimal.showChartCenterSubtitle, isFalse);
      expect(minimal.showChartCenterPlace, isFalse);
    },
  );
}
