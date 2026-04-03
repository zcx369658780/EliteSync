import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AstroChartDisplayPrefs {
  const AstroChartDisplayPrefs({
    required this.showPlanetSummary,
    required this.showHouseSummary,
    required this.showAspectSummary,
    required this.showTechnicalParameters,
    required this.compactDensity,
  });

  final bool showPlanetSummary;
  final bool showHouseSummary;
  final bool showAspectSummary;
  final bool showTechnicalParameters;
  final bool compactDensity;

  factory AstroChartDisplayPrefs.defaults() => const AstroChartDisplayPrefs(
        showPlanetSummary: true,
        showHouseSummary: true,
        showAspectSummary: true,
        showTechnicalParameters: true,
        compactDensity: false,
      );

  AstroChartDisplayPrefs copyWith({
    bool? showPlanetSummary,
    bool? showHouseSummary,
    bool? showAspectSummary,
    bool? showTechnicalParameters,
    bool? compactDensity,
  }) {
    return AstroChartDisplayPrefs(
      showPlanetSummary: showPlanetSummary ?? this.showPlanetSummary,
      showHouseSummary: showHouseSummary ?? this.showHouseSummary,
      showAspectSummary: showAspectSummary ?? this.showAspectSummary,
      showTechnicalParameters:
          showTechnicalParameters ?? this.showTechnicalParameters,
      compactDensity: compactDensity ?? this.compactDensity,
    );
  }

  Map<String, dynamic> toJson() => {
        'showPlanetSummary': showPlanetSummary,
        'showHouseSummary': showHouseSummary,
        'showAspectSummary': showAspectSummary,
        'showTechnicalParameters': showTechnicalParameters,
        'compactDensity': compactDensity,
      };

  factory AstroChartDisplayPrefs.fromJson(Map<String, dynamic> json) {
    return AstroChartDisplayPrefs(
      showPlanetSummary: json['showPlanetSummary'] == true,
      showHouseSummary: json['showHouseSummary'] == true,
      showAspectSummary: json['showAspectSummary'] == true,
      showTechnicalParameters: json['showTechnicalParameters'] == true,
      compactDensity: json['compactDensity'] == true,
    );
  }
}

class AstroChartSettingsNotifier extends Notifier<AstroChartDisplayPrefs> {
  bool _hydrated = false;

  @override
  AstroChartDisplayPrefs build() {
    if (!_hydrated) {
      _hydrated = true;
      unawaited(_hydrate());
    }
    return AstroChartDisplayPrefs.defaults();
  }

  Future<void> _hydrate() async {
    final raw = await ref.read(localStorageProvider).getJson(
          CacheKeys.astroChartPreferences,
        );
    if (raw == null) return;
    state = AstroChartDisplayPrefs.fromJson(raw);
  }

  Future<void> _persist(AstroChartDisplayPrefs prefs) async {
    await ref.read(localStorageProvider).setJson(
          CacheKeys.astroChartPreferences,
          prefs.toJson(),
        );
  }

  Future<void> setShowPlanetSummary(bool value) async {
    state = state.copyWith(showPlanetSummary: value);
    await _persist(state);
  }

  Future<void> setShowHouseSummary(bool value) async {
    state = state.copyWith(showHouseSummary: value);
    await _persist(state);
  }

  Future<void> setShowAspectSummary(bool value) async {
    state = state.copyWith(showAspectSummary: value);
    await _persist(state);
  }

  Future<void> setShowTechnicalParameters(bool value) async {
    state = state.copyWith(showTechnicalParameters: value);
    await _persist(state);
  }

  Future<void> setCompactDensity(bool value) async {
    state = state.copyWith(compactDensity: value);
    await _persist(state);
  }
}

final astroChartSettingsProvider =
    NotifierProvider<AstroChartSettingsNotifier, AstroChartDisplayPrefs>(
  AstroChartSettingsNotifier.new,
);
