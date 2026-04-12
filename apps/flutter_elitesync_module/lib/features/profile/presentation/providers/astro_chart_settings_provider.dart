import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

enum AstroChartDisplayPreset { full, balanced, minimal }

enum AstroChartWorkbenchPreset { standard, classical, modern }

enum AstroChartRouteMode { standard, classical, modern }

enum AstroZodiacMode { tropical, sidereal }

enum AstroHouseSystem { whole, placidus, alcabitius }

enum AstroAspectMode { major, standard, extended }

enum AstroOrbPreset { tight, standard, wide }

enum AstroPointMode { core, extended, full }

class AstroChartDisplayPrefs {
  const AstroChartDisplayPrefs({
    required this.showPlanetSummary,
    required this.showHouseSummary,
    required this.showAspectSummary,
    required this.showTechnicalParameters,
    required this.compactDensity,
    required this.showChartSignGridLines,
    required this.showChartSignLabels,
    required this.showChartHouseLines,
    required this.showChartHouseNumbers,
    required this.showChartAspectLines,
    required this.showChartPlanetConnectors,
    required this.showChartPlanetMarkers,
    required this.showChartPlanetLabels,
    required this.showChartCenterTitle,
    required this.showChartCenterSubtitle,
    required this.showChartCenterPlace,
  });

  final bool showPlanetSummary;
  final bool showHouseSummary;
  final bool showAspectSummary;
  final bool showTechnicalParameters;
  final bool compactDensity;
  final bool showChartSignGridLines;
  final bool showChartSignLabels;
  final bool showChartHouseLines;
  final bool showChartHouseNumbers;
  final bool showChartAspectLines;
  final bool showChartPlanetConnectors;
  final bool showChartPlanetMarkers;
  final bool showChartPlanetLabels;
  final bool showChartCenterTitle;
  final bool showChartCenterSubtitle;
  final bool showChartCenterPlace;

  factory AstroChartDisplayPrefs.defaults() => const AstroChartDisplayPrefs(
    showPlanetSummary: true,
    showHouseSummary: true,
    showAspectSummary: true,
    showTechnicalParameters: true,
    compactDensity: false,
    showChartSignGridLines: true,
    showChartSignLabels: true,
    showChartHouseLines: true,
    showChartHouseNumbers: true,
    showChartAspectLines: true,
    showChartPlanetConnectors: true,
    showChartPlanetMarkers: true,
    showChartPlanetLabels: true,
    showChartCenterTitle: true,
    showChartCenterSubtitle: true,
    showChartCenterPlace: true,
  );

  factory AstroChartDisplayPrefs.forPreset(AstroChartDisplayPreset preset) {
    switch (preset) {
      case AstroChartDisplayPreset.full:
        return AstroChartDisplayPrefs.defaults();
      case AstroChartDisplayPreset.balanced:
        return const AstroChartDisplayPrefs(
          showPlanetSummary: true,
          showHouseSummary: true,
          showAspectSummary: true,
          showTechnicalParameters: true,
          compactDensity: true,
          showChartSignGridLines: false,
          showChartSignLabels: true,
          showChartHouseLines: true,
          showChartHouseNumbers: false,
          showChartAspectLines: true,
          showChartPlanetConnectors: false,
          showChartPlanetMarkers: true,
          showChartPlanetLabels: true,
          showChartCenterTitle: true,
          showChartCenterSubtitle: false,
          showChartCenterPlace: false,
        );
      case AstroChartDisplayPreset.minimal:
        return const AstroChartDisplayPrefs(
          showPlanetSummary: false,
          showHouseSummary: false,
          showAspectSummary: false,
          showTechnicalParameters: false,
          compactDensity: true,
          showChartSignGridLines: false,
          showChartSignLabels: false,
          showChartHouseLines: true,
          showChartHouseNumbers: false,
          showChartAspectLines: false,
          showChartPlanetConnectors: false,
          showChartPlanetMarkers: true,
          showChartPlanetLabels: true,
          showChartCenterTitle: true,
          showChartCenterSubtitle: false,
          showChartCenterPlace: false,
        );
    }
  }

  AstroChartDisplayPrefs copyWith({
    bool? showPlanetSummary,
    bool? showHouseSummary,
    bool? showAspectSummary,
    bool? showTechnicalParameters,
    bool? compactDensity,
    bool? showChartSignGridLines,
    bool? showChartSignLabels,
    bool? showChartHouseLines,
    bool? showChartHouseNumbers,
    bool? showChartAspectLines,
    bool? showChartPlanetConnectors,
    bool? showChartPlanetMarkers,
    bool? showChartPlanetLabels,
    bool? showChartCenterTitle,
    bool? showChartCenterSubtitle,
    bool? showChartCenterPlace,
  }) {
    return AstroChartDisplayPrefs(
      showPlanetSummary: showPlanetSummary ?? this.showPlanetSummary,
      showHouseSummary: showHouseSummary ?? this.showHouseSummary,
      showAspectSummary: showAspectSummary ?? this.showAspectSummary,
      showTechnicalParameters:
          showTechnicalParameters ?? this.showTechnicalParameters,
      compactDensity: compactDensity ?? this.compactDensity,
      showChartSignGridLines:
          showChartSignGridLines ?? this.showChartSignGridLines,
      showChartSignLabels: showChartSignLabels ?? this.showChartSignLabels,
      showChartHouseLines: showChartHouseLines ?? this.showChartHouseLines,
      showChartHouseNumbers:
          showChartHouseNumbers ?? this.showChartHouseNumbers,
      showChartAspectLines: showChartAspectLines ?? this.showChartAspectLines,
      showChartPlanetConnectors:
          showChartPlanetConnectors ?? this.showChartPlanetConnectors,
      showChartPlanetMarkers:
          showChartPlanetMarkers ?? this.showChartPlanetMarkers,
      showChartPlanetLabels:
          showChartPlanetLabels ?? this.showChartPlanetLabels,
      showChartCenterTitle: showChartCenterTitle ?? this.showChartCenterTitle,
      showChartCenterSubtitle:
          showChartCenterSubtitle ?? this.showChartCenterSubtitle,
      showChartCenterPlace: showChartCenterPlace ?? this.showChartCenterPlace,
    );
  }

  Map<String, dynamic> toJson() => {
    'showPlanetSummary': showPlanetSummary,
    'showHouseSummary': showHouseSummary,
    'showAspectSummary': showAspectSummary,
    'showTechnicalParameters': showTechnicalParameters,
    'compactDensity': compactDensity,
    'showChartSignGridLines': showChartSignGridLines,
    'showChartSignLabels': showChartSignLabels,
    'showChartHouseLines': showChartHouseLines,
    'showChartHouseNumbers': showChartHouseNumbers,
    'showChartAspectLines': showChartAspectLines,
    'showChartPlanetConnectors': showChartPlanetConnectors,
    'showChartPlanetMarkers': showChartPlanetMarkers,
    'showChartPlanetLabels': showChartPlanetLabels,
    'showChartCenterTitle': showChartCenterTitle,
    'showChartCenterSubtitle': showChartCenterSubtitle,
    'showChartCenterPlace': showChartCenterPlace,
  };

  factory AstroChartDisplayPrefs.fromJson(Map<String, dynamic> json) {
    final legacySignLabels = _readBool(json, 'showChartSignLabels', true);
    final legacyHouseGuides = _readBool(json, 'showChartHouseGuides', true);
    final legacyPlanetLabels = _readBool(json, 'showChartPlanetLabels', true);
    final legacyCenterInfo = _readBool(json, 'showChartCenterInfo', true);

    return AstroChartDisplayPrefs(
      showPlanetSummary: _readBool(json, 'showPlanetSummary', true),
      showHouseSummary: _readBool(json, 'showHouseSummary', true),
      showAspectSummary: _readBool(json, 'showAspectSummary', true),
      showTechnicalParameters: _readBool(json, 'showTechnicalParameters', true),
      compactDensity: _readBool(json, 'compactDensity', false),
      showChartSignGridLines: _readBool(
        json,
        'showChartSignGridLines',
        legacySignLabels,
      ),
      showChartSignLabels: _readBool(
        json,
        'showChartSignLabels',
        legacySignLabels,
      ),
      showChartHouseLines: _readBool(
        json,
        'showChartHouseLines',
        legacyHouseGuides,
      ),
      showChartHouseNumbers: _readBool(
        json,
        'showChartHouseNumbers',
        legacyHouseGuides,
      ),
      showChartAspectLines: _readBool(json, 'showChartAspectLines', true),
      showChartPlanetConnectors: _readBool(
        json,
        'showChartPlanetConnectors',
        legacyPlanetLabels,
      ),
      showChartPlanetMarkers: _readBool(json, 'showChartPlanetMarkers', true),
      showChartPlanetLabels: _readBool(
        json,
        'showChartPlanetLabels',
        legacyPlanetLabels,
      ),
      showChartCenterTitle: _readBool(
        json,
        'showChartCenterTitle',
        legacyCenterInfo,
      ),
      showChartCenterSubtitle: _readBool(
        json,
        'showChartCenterSubtitle',
        legacyCenterInfo,
      ),
      showChartCenterPlace: _readBool(
        json,
        'showChartCenterPlace',
        legacyCenterInfo,
      ),
    );
  }
}

class AstroChartWorkbenchPrefs {
  const AstroChartWorkbenchPrefs({
    required this.zodiacMode,
    required this.houseSystem,
    required this.aspectMode,
    required this.orbPreset,
    required this.pointMode,
  });

  final AstroZodiacMode zodiacMode;
  final AstroHouseSystem houseSystem;
  final AstroAspectMode aspectMode;
  final AstroOrbPreset orbPreset;
  final AstroPointMode pointMode;

  factory AstroChartWorkbenchPrefs.defaults() => const AstroChartWorkbenchPrefs(
    zodiacMode: AstroZodiacMode.tropical,
    houseSystem: AstroHouseSystem.whole,
    aspectMode: AstroAspectMode.standard,
    orbPreset: AstroOrbPreset.standard,
    pointMode: AstroPointMode.full,
  );

  factory AstroChartWorkbenchPrefs.forRouteMode(AstroChartRouteMode routeMode) {
    switch (routeMode) {
      case AstroChartRouteMode.standard:
        return AstroChartWorkbenchPrefs.defaults();
      case AstroChartRouteMode.classical:
        return AstroChartWorkbenchPrefs.forPreset(
          AstroChartWorkbenchPreset.classical,
        );
      case AstroChartRouteMode.modern:
        return AstroChartWorkbenchPrefs.forPreset(
          AstroChartWorkbenchPreset.modern,
        );
    }
  }

  factory AstroChartWorkbenchPrefs.forPreset(AstroChartWorkbenchPreset preset) {
    switch (preset) {
      case AstroChartWorkbenchPreset.standard:
        return AstroChartWorkbenchPrefs.defaults();
      case AstroChartWorkbenchPreset.classical:
        return const AstroChartWorkbenchPrefs(
          zodiacMode: AstroZodiacMode.sidereal,
          houseSystem: AstroHouseSystem.whole,
          aspectMode: AstroAspectMode.major,
          orbPreset: AstroOrbPreset.tight,
          pointMode: AstroPointMode.core,
        );
      case AstroChartWorkbenchPreset.modern:
        return const AstroChartWorkbenchPrefs(
          zodiacMode: AstroZodiacMode.tropical,
          houseSystem: AstroHouseSystem.placidus,
          aspectMode: AstroAspectMode.extended,
          orbPreset: AstroOrbPreset.wide,
          pointMode: AstroPointMode.full,
        );
    }
  }

  AstroChartWorkbenchPrefs copyWith({
    AstroZodiacMode? zodiacMode,
    AstroHouseSystem? houseSystem,
    AstroAspectMode? aspectMode,
    AstroOrbPreset? orbPreset,
    AstroPointMode? pointMode,
  }) {
    return AstroChartWorkbenchPrefs(
      zodiacMode: zodiacMode ?? this.zodiacMode,
      houseSystem: houseSystem ?? this.houseSystem,
      aspectMode: aspectMode ?? this.aspectMode,
      orbPreset: orbPreset ?? this.orbPreset,
      pointMode: pointMode ?? this.pointMode,
    );
  }

  Map<String, dynamic> toJson() => {
    'zodiacMode': zodiacMode.name,
    'houseSystem': houseSystem.name,
    'aspectMode': aspectMode.name,
    'orbPreset': orbPreset.name,
    'pointMode': pointMode.name,
  };

  factory AstroChartWorkbenchPrefs.fromJson(Map<String, dynamic> json) {
    return AstroChartWorkbenchPrefs(
      zodiacMode: _readEnum(
        json,
        'zodiacMode',
        AstroZodiacMode.values,
        AstroZodiacMode.tropical,
      ),
      houseSystem: _readEnum(
        json,
        'houseSystem',
        AstroHouseSystem.values,
        AstroHouseSystem.whole,
      ),
      aspectMode: _readEnum(
        json,
        'aspectMode',
        AstroAspectMode.values,
        AstroAspectMode.standard,
      ),
      orbPreset: _readEnum(
        json,
        'orbPreset',
        AstroOrbPreset.values,
        AstroOrbPreset.standard,
      ),
      pointMode: _readEnum(
        json,
        'pointMode',
        AstroPointMode.values,
        AstroPointMode.full,
      ),
    );
  }
}

class AstroChartRoutePrefs {
  const AstroChartRoutePrefs({required this.routeMode});

  final AstroChartRouteMode routeMode;

  factory AstroChartRoutePrefs.defaults() =>
      const AstroChartRoutePrefs(routeMode: AstroChartRouteMode.standard);

  factory AstroChartRoutePrefs.forRouteMode(AstroChartRouteMode routeMode) {
    return AstroChartRoutePrefs(routeMode: routeMode);
  }

  AstroChartRoutePrefs copyWith({AstroChartRouteMode? routeMode}) {
    return AstroChartRoutePrefs(routeMode: routeMode ?? this.routeMode);
  }

  Map<String, dynamic> toJson() => {'routeMode': routeMode.name};

  factory AstroChartRoutePrefs.fromJson(Map<String, dynamic> json) {
    return AstroChartRoutePrefs(
      routeMode: _readEnum(
        json,
        'routeMode',
        AstroChartRouteMode.values,
        AstroChartRouteMode.standard,
      ),
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
    final raw = await ref
        .read(localStorageProvider)
        .getJson(CacheKeys.astroChartPreferences);
    if (raw == null) return;
    state = AstroChartDisplayPrefs.fromJson(raw);
  }

  Future<void> _persist(AstroChartDisplayPrefs prefs) async {
    await ref
        .read(localStorageProvider)
        .setJson(CacheKeys.astroChartPreferences, prefs.toJson());
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

  Future<void> setShowChartSignGridLines(bool value) async {
    state = state.copyWith(showChartSignGridLines: value);
    await _persist(state);
  }

  Future<void> setShowChartSignLabels(bool value) async {
    state = state.copyWith(showChartSignLabels: value);
    await _persist(state);
  }

  Future<void> setShowChartHouseLines(bool value) async {
    state = state.copyWith(showChartHouseLines: value);
    await _persist(state);
  }

  Future<void> setShowChartHouseNumbers(bool value) async {
    state = state.copyWith(showChartHouseNumbers: value);
    await _persist(state);
  }

  Future<void> setShowChartAspectLines(bool value) async {
    state = state.copyWith(showChartAspectLines: value);
    await _persist(state);
  }

  Future<void> setShowChartPlanetConnectors(bool value) async {
    state = state.copyWith(showChartPlanetConnectors: value);
    await _persist(state);
  }

  Future<void> setShowChartPlanetMarkers(bool value) async {
    state = state.copyWith(showChartPlanetMarkers: value);
    await _persist(state);
  }

  Future<void> setShowChartPlanetLabels(bool value) async {
    state = state.copyWith(showChartPlanetLabels: value);
    await _persist(state);
  }

  Future<void> setShowChartCenterTitle(bool value) async {
    state = state.copyWith(showChartCenterTitle: value);
    await _persist(state);
  }

  Future<void> setShowChartCenterSubtitle(bool value) async {
    state = state.copyWith(showChartCenterSubtitle: value);
    await _persist(state);
  }

  Future<void> setShowChartCenterPlace(bool value) async {
    state = state.copyWith(showChartCenterPlace: value);
    await _persist(state);
  }

  Future<void> resetToDefaults() async {
    state = AstroChartDisplayPrefs.defaults();
    await _persist(state);
  }

  Future<void> applyPreset(AstroChartDisplayPreset preset) async {
    state = AstroChartDisplayPrefs.forPreset(preset);
    await _persist(state);
  }
}

class AstroChartWorkbenchNotifier extends Notifier<AstroChartWorkbenchPrefs> {
  bool _hydrated = false;

  @override
  AstroChartWorkbenchPrefs build() {
    if (!_hydrated) {
      _hydrated = true;
      unawaited(_hydrate());
    }
    return AstroChartWorkbenchPrefs.defaults();
  }

  Future<void> _hydrate() async {
    final raw = await ref
        .read(localStorageProvider)
        .getJson(CacheKeys.astroChartWorkbenchPreferences);
    if (raw == null) return;
    state = AstroChartWorkbenchPrefs.fromJson(raw);
  }

  Future<void> _persist(AstroChartWorkbenchPrefs prefs) async {
    await ref
        .read(localStorageProvider)
        .setJson(CacheKeys.astroChartWorkbenchPreferences, prefs.toJson());
  }

  Future<void> setZodiacMode(AstroZodiacMode value) async {
    state = state.copyWith(zodiacMode: value);
    await _persist(state);
  }

  Future<void> setHouseSystem(AstroHouseSystem value) async {
    state = state.copyWith(houseSystem: value);
    await _persist(state);
  }

  Future<void> setAspectMode(AstroAspectMode value) async {
    state = state.copyWith(aspectMode: value);
    await _persist(state);
  }

  Future<void> setOrbPreset(AstroOrbPreset value) async {
    state = state.copyWith(orbPreset: value);
    await _persist(state);
  }

  Future<void> setPointMode(AstroPointMode value) async {
    state = state.copyWith(pointMode: value);
    await _persist(state);
  }

  Future<void> resetToDefaults() async {
    state = AstroChartWorkbenchPrefs.defaults();
    await _persist(state);
  }

  Future<void> applyPreset(AstroChartWorkbenchPreset preset) async {
    state = AstroChartWorkbenchPrefs.forPreset(preset);
    await _persist(state);
  }
}

class AstroChartRouteNotifier extends Notifier<AstroChartRoutePrefs> {
  bool _hydrated = false;

  @override
  AstroChartRoutePrefs build() {
    if (!_hydrated) {
      _hydrated = true;
      unawaited(_hydrate());
    }
    return AstroChartRoutePrefs.defaults();
  }

  Future<void> _hydrate() async {
    final raw = await ref
        .read(localStorageProvider)
        .getJson(CacheKeys.astroChartRoutePreferences);
    if (raw == null) return;
    state = AstroChartRoutePrefs.fromJson(raw);
  }

  Future<void> _persist(AstroChartRoutePrefs prefs) async {
    await ref
        .read(localStorageProvider)
        .setJson(CacheKeys.astroChartRoutePreferences, prefs.toJson());
  }

  Future<void> setRouteMode(AstroChartRouteMode value) async {
    state = state.copyWith(routeMode: value);
    await _persist(state);
  }

  Future<void> resetToDefaults() async {
    state = AstroChartRoutePrefs.defaults();
    await _persist(state);
  }
}

final astroChartSettingsProvider =
    NotifierProvider<AstroChartSettingsNotifier, AstroChartDisplayPrefs>(
      AstroChartSettingsNotifier.new,
    );

final astroChartWorkbenchProvider =
    NotifierProvider<AstroChartWorkbenchNotifier, AstroChartWorkbenchPrefs>(
      AstroChartWorkbenchNotifier.new,
    );

final astroChartRouteProvider =
    NotifierProvider<AstroChartRouteNotifier, AstroChartRoutePrefs>(
      AstroChartRouteNotifier.new,
    );

bool _readBool(Map<String, dynamic> json, String key, bool defaultValue) {
  final value = json[key];
  if (value is bool) return value;
  return defaultValue;
}

T _readEnum<T extends Enum>(
  Map<String, dynamic> json,
  String key,
  List<T> values,
  T defaultValue,
) {
  final raw = json[key]?.toString().trim();
  if (raw == null || raw.isEmpty) return defaultValue;
  for (final value in values) {
    if (value.name == raw) return value;
  }
  return defaultValue;
}
