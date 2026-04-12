import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_chart_settings_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_errors.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';
import 'package:flutter_elitesync_module/shared/providers/session_provider.dart';

class AstroAdvancedPreviewRequests {
  const AstroAdvancedPreviewRequests({
    required this.pair,
    required this.comparison,
    required this.transit,
    required this.returnChart,
  });

  final Map<String, dynamic> pair;
  final Map<String, dynamic> comparison;
  final Map<String, dynamic> transit;
  final Map<String, dynamic> returnChart;
}

class AstroAdvancedPreviewItem {
  const AstroAdvancedPreviewItem({
    required this.title,
    required this.summary,
    required this.routeMode,
    required this.generatedAt,
    required this.primaryName,
    required this.secondaryName,
    required this.primaryPointCount,
    required this.secondaryPointCount,
    required this.aspectCount,
    required this.chartKind,
    required this.advancedMode,
    this.pairMode,
    this.returnType,
    this.returnYear,
    this.relationshipScoreDescription,
    this.relationshipScoreValue,
  });

  final String title;
  final String summary;
  final String routeMode;
  final String generatedAt;
  final String primaryName;
  final String secondaryName;
  final int primaryPointCount;
  final int secondaryPointCount;
  final int aspectCount;
  final String chartKind;
  final String advancedMode;
  final String? pairMode;
  final String? returnType;
  final int? returnYear;
  final String? relationshipScoreDescription;
  final num? relationshipScoreValue;

  String get modeLabel {
    return switch (advancedMode) {
      'pair' => '合盘',
      'transit' => '行运',
      'return' => '返照',
      _ => advancedMode,
    };
  }

  String get routeLabel => _routeModeLabelText(routeMode);

  String get metricsLabel =>
      '主档 $primaryPointCount 点位 / 对照 $secondaryPointCount 点位 / $aspectCount 相位';

  List<String> get badges => [
    '路线：$routeLabel',
    '模式：$modeLabel',
    if ((pairMode ?? '').isNotEmpty) 'pair_mode：$pairMode',
    if ((returnType ?? '').isNotEmpty) '返照：$returnType',
    if (returnYear != null) '返照年：$returnYear',
  ];

  List<String> toMarkdownLines() => [
    '- 模式：$modeLabel',
    '- 路线：$routeLabel',
    '- 图表类型：$chartKind',
    '- 标题：$title',
    '- 概要：$summary',
    '- 主档：$primaryName',
    '- 对照：$secondaryName',
    '- 计数：${metricsLabel.replaceAll(' / ', '，')}',
    if (pairMode != null) '- pair_mode：$pairMode',
    if (returnType != null) '- return_type：$returnType',
    if (returnYear != null) '- return_year：$returnYear',
    if ((relationshipScoreDescription ?? '').trim().isNotEmpty)
      '- 关系评分：$relationshipScoreDescription',
  ];
}

class AstroAdvancedPreviewBundle {
  const AstroAdvancedPreviewBundle({
    required this.routeMode,
    required this.requests,
    required this.pair,
    required this.comparison,
    required this.transit,
    required this.returnChart,
    this.offlineFallback = false,
  });

  final AstroChartRouteMode routeMode;
  final AstroAdvancedPreviewRequests requests;
  final AstroAdvancedPreviewItem pair;
  final AstroAdvancedPreviewItem comparison;
  final AstroAdvancedPreviewItem transit;
  final AstroAdvancedPreviewItem returnChart;
  final bool offlineFallback;

  List<AstroAdvancedPreviewItem> get items =>
      [pair, comparison, transit, returnChart];

  List<String> toMarkdownLines() => [
    '# 3.7 高级能力预览',
    '- 报告性质：derived-only / display-only / advanced-context',
    '- 当前路线：${_routeModeLabel(routeMode)}',
    if (offlineFallback)
      '- 说明：当前使用离线样例预览，服务端高级接口暂不可用。',
    '- 说明：预览数据使用当前画像与 scaffold 对照主体生成，不回写 canonical truth。',
    '',
    ...pair.toMarkdownLines(),
    '',
    ...comparison.toMarkdownLines(),
    '',
    ...transit.toMarkdownLines(),
    '',
    ...returnChart.toMarkdownLines(),
  ];
}

final astroAdvancedPreviewProvider =
    FutureProvider<AstroAdvancedPreviewBundle?>((ref) async {
      try {
        final routeMode = ref.watch(astroChartRouteProvider).routeMode;
        final summary = await ref.watch(astroSummaryProvider.future);
        if (summary == null) return null;

        final requests = buildAstroAdvancedPreviewRequests(summary, routeMode);

        final pairPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/pair',
          body: requests.pair,
        );
        final comparisonPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/pair',
          body: requests.comparison,
        );
        final transitPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/transit',
          body: requests.transit,
        );
        final returnPayload = await _postAdvancedProfile(
          ref,
          path: '/api/v1/profile/astro/return',
          body: requests.returnChart,
        );

        return AstroAdvancedPreviewBundle(
          routeMode: routeMode,
          requests: requests,
          pair: _buildAdvancedPreviewItem(
            title: '合盘预览',
            payload: pairPayload,
          ),
          comparison: _buildAdvancedPreviewItem(
            title: '对比盘预览',
            payload: comparisonPayload,
          ),
          transit: _buildAdvancedPreviewItem(
            title: '行运预览',
            payload: transitPayload,
          ),
          returnChart: _buildAdvancedPreviewItem(
            title: '返照预览',
            payload: returnPayload,
          ),
        );
      } catch (_) {
        final routeMode = ref.read(astroChartRouteProvider).routeMode;
        final fallbackProfile = <String, dynamic>{'name': 'EliteSync'};
        final fallbackRequests = buildAstroAdvancedPreviewRequests(
          fallbackProfile,
          routeMode,
        );
        return _buildOfflineAdvancedPreviewBundle(
          fallbackProfile,
          routeMode,
          fallbackRequests,
        );
      }
    });

Future<Map<String, dynamic>> _postAdvancedProfile(
  Ref ref, {
  required String path,
  required Map<String, dynamic> body,
}) async {
  final result = await ref
      .read(apiClientProvider)
      .post(path, body: body)
      .timeout(const Duration(seconds: 12));

  if (result is NetworkSuccess<Map<String, dynamic>>) {
    final data = result.data;
    if (data['ok'] == true && data['profile'] is Map<String, dynamic>) {
      return Map<String, dynamic>.from(data['profile'] as Map<String, dynamic>);
    }
    return data;
  }

  final failure = result as NetworkFailure<Map<String, dynamic>>;
  if (failure.statusCode == 401 || failure.statusCode == 403) {
    await ref.read(sessionProvider.notifier).setUnauthenticated();
  }

  throw AstroProfileApiException(
    message: failure.message,
    statusCode: failure.statusCode,
    code: failure.code,
  );
}

AstroAdvancedPreviewItem _buildAdvancedPreviewItem({
  required String title,
  required Map<String, dynamic> payload,
}) {
  final advancedSummary = _map(payload['advanced_summary']);
  final primary = _readText(advancedSummary, 'primary_name');
  final secondary = _readText(advancedSummary, 'secondary_name');
  final chartKind = payload['engine_info'] is Map<String, dynamic>
      ? _readText(_map(payload['engine_info']), 'chart_kind') ?? '-'
      : '-';
  final advancedMode = _readText(payload, 'advanced_mode') ?? '-';
  final routeMode = _readText(payload, 'route_mode') ?? 'standard';
  final generatedAt = astroDateTimeLabel(payload['generated_at']);
  final primaryCount = _list(payload['primary_planets_data']).length;
  final secondaryCount = _list(payload['secondary_planets_data']).length;
  final aspectCount = _list(payload['aspects_data']).length;
  final pairMode = _readText(payload, 'pair_mode');
  final returnType = _readText(advancedSummary, 'return_type');
  final returnYear = advancedSummary['return_year'] is int
      ? advancedSummary['return_year'] as int
      : int.tryParse(advancedSummary['return_year']?.toString() ?? '');
  final relationshipScoreDescription = _readText(
    advancedSummary,
    'relationship_score_description',
  );
  final relationshipScoreValue =
      advancedSummary['relationship_score_value'] as num?;

  return AstroAdvancedPreviewItem(
    title: title,
    summary: _buildSummaryText(
      mode: advancedMode,
      primary: primary ?? '',
      secondary: secondary ?? '',
      aspectCount: aspectCount,
      relationshipScoreDescription: relationshipScoreDescription,
      returnType: returnType,
      returnYear: returnYear,
    ),
    routeMode: routeMode,
    generatedAt: generatedAt,
    primaryName: primary?.isNotEmpty == true ? primary! : '主档',
    secondaryName: secondary?.isNotEmpty == true ? secondary! : '对照档',
    primaryPointCount: primaryCount,
    secondaryPointCount: secondaryCount,
    aspectCount: aspectCount,
    chartKind: chartKind,
    advancedMode: advancedMode,
    pairMode: pairMode?.isEmpty == true ? null : pairMode,
    returnType: returnType?.isEmpty == true ? null : returnType,
    returnYear: returnYear,
    relationshipScoreDescription: relationshipScoreDescription?.isEmpty == true
        ? null
        : relationshipScoreDescription,
    relationshipScoreValue: relationshipScoreValue,
  );
}

AstroAdvancedPreviewBundle _buildOfflineAdvancedPreviewBundle(
  Map<String, dynamic> profile,
  AstroChartRouteMode routeMode,
  AstroAdvancedPreviewRequests requests,
) {
  final nowLabel = astroDateTimeLabel(DateTime.now());
  final subject = _subjectName(profile);
  return AstroAdvancedPreviewBundle(
    routeMode: routeMode,
    requests: requests,
    offlineFallback: true,
    pair: AstroAdvancedPreviewItem(
      title: '合盘预览（离线）',
      summary: '$subject × 对照档 · 离线样例 · 9 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '对照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 9,
      chartKind: 'synastry',
      advancedMode: 'pair',
      pairMode: 'synastry',
      relationshipScoreDescription: '离线样例',
      relationshipScoreValue: 78,
    ),
    comparison: AstroAdvancedPreviewItem(
      title: '对比盘预览（离线）',
      summary: '$subject × 对比档 · 离线样例 · 10 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '对比档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 10,
      chartKind: 'comparison',
      advancedMode: 'pair',
      pairMode: 'comparison',
      relationshipScoreDescription: '对照差异',
      relationshipScoreValue: 61,
    ),
    transit: AstroAdvancedPreviewItem(
      title: '行运预览（离线）',
      summary: '$subject · 时间维度样例 · 6 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '行运档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 6,
      chartKind: 'transit',
      advancedMode: 'transit',
    ),
    returnChart: AstroAdvancedPreviewItem(
      title: '返照预览（离线）',
      summary: '$subject · Lunar 返照样例 · 5 相位',
      routeMode: routeMode.name,
      generatedAt: nowLabel,
      primaryName: subject,
      secondaryName: '返照档',
      primaryPointCount: 20,
      secondaryPointCount: 20,
      aspectCount: 5,
      chartKind: 'return',
      advancedMode: 'return',
      returnType: 'Lunar',
      returnYear: DateTime.now().year,
    ),
  );
}

String _buildSummaryText({
  required String mode,
  required String primary,
  required String secondary,
  required int aspectCount,
  String? relationshipScoreDescription,
  String? returnType,
  int? returnYear,
}) {
  return switch (mode) {
    'pair' =>
      '${primary.isEmpty ? '主档' : primary} × ${secondary.isEmpty ? '对照档' : secondary} · ${relationshipScoreDescription ?? '关系评分预览'} · $aspectCount 相位',
    'transit' =>
      '${primary.isEmpty ? '主档' : primary} × ${secondary.isEmpty ? '过境档' : secondary} · $aspectCount 相位',
    'return' =>
      '${primary.isEmpty ? '主档' : primary} · ${(returnType ?? '返照').trim()}${returnYear == null ? '' : ' $returnYear'} · $aspectCount 相位',
    _ => '$mode · $aspectCount 相位',
  };
}

AstroAdvancedPreviewRequests buildAstroAdvancedPreviewRequests(
  Map<String, dynamic> profile,
  AstroChartRouteMode routeMode, {
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final natal = _buildSubjectRequest(profile, name: _subjectName(profile));
  final pair = _buildSubjectRequest(
    profile,
    name: '${natal['name']} 对照',
    birthday: _shiftDate(natal['birthday']?.toString(), 17, referenceNow: now),
    birthTime: _shiftTime(natal['birth_time']?.toString(), 97),
  );
  final transit = _buildSubjectRequest(
    profile,
    name: '行运 ${_subjectName(profile)}',
    birthday: _formatDate(now),
    birthTime: _formatTime(now),
  );
  final comparisonSecond = _buildSubjectRequest(
    profile,
    name: '${natal['name']} 对比',
    birthday: _shiftDate(natal['birthday']?.toString(), -23, referenceNow: now),
    birthTime: _shiftTime(natal['birth_time']?.toString(), -83),
  );
  final returnChart = {
    'natal': natal,
    'return_year': now.year,
    'return_type': 'Lunar',
    'route_mode': routeMode.name,
    'return_place': _readString(profile, [
      'birth_place',
      'private_birth_place',
    ]),
    'return_lat': _readDouble(profile, ['birth_lat', 'lat']),
    'return_lng': _readDouble(profile, ['birth_lng', 'lng']),
    'return_tz_str': _readString(profile, ['tz_str']) ?? 'Asia/Shanghai',
    'return_nation': _readString(profile, ['nation']) ?? 'CN',
  };

  return AstroAdvancedPreviewRequests(
    pair: {
      'first': natal,
      'second': pair,
      'pair_mode': 'synastry',
      'route_mode': routeMode.name,
    },
    comparison: {
      'first': natal,
      'second': comparisonSecond,
      'pair_mode': 'comparison',
      'route_mode': routeMode.name,
    },
    transit: {'natal': natal, 'transit': transit, 'route_mode': routeMode.name},
    returnChart: returnChart,
  );
}

Map<String, dynamic> _buildSubjectRequest(
  Map<String, dynamic> profile, {
  String? name,
  String? birthday,
  String? birthTime,
}) {
  final resolvedName = (name ?? _subjectName(profile)).trim();
  return <String, dynamic>{
    'name': resolvedName.isEmpty ? 'EliteSync' : resolvedName,
    'birthday':
        (birthday ??
                _readString(profile, ['birthday']) ??
                _formatDate(DateTime.now()))
            .trim(),
    'birth_time': (birthTime ?? _readString(profile, ['birth_time']) ?? '12:00')
        .trim(),
    'birth_place': _readString(profile, ['birth_place', 'private_birth_place']),
    'birth_lat': _readDouble(profile, ['birth_lat', 'lat']),
    'birth_lng': _readDouble(profile, ['birth_lng', 'lng']),
    'tz_str': _readString(profile, ['tz_str']) ?? 'Asia/Shanghai',
    'nation': _readString(profile, ['nation']) ?? 'CN',
  };
}

String _subjectName(Map<String, dynamic> profile) {
  final raw = _readString(profile, ['name', 'nickname']);
  if (raw != null && raw.trim().isNotEmpty) return raw.trim();
  return 'EliteSync';
}

String _shiftDate(String? value, int days, {DateTime? referenceNow}) {
  final parsed = _parseDate(value);
  if (parsed == null) {
    return _formatDate(
      (referenceNow ?? DateTime.now()).add(Duration(days: days)),
    );
  }
  return _formatDate(parsed.add(Duration(days: days)));
}

String _shiftTime(String? value, int minutes) {
  final parsed = _parseTime(value);
  if (parsed == null) return '12:00';
  final shifted = parsed.add(Duration(minutes: minutes));
  return _formatTime(shifted);
}

DateTime? _parseDate(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return DateTime(parsed.year, parsed.month, parsed.day);
  }
  final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  return DateTime(
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
    int.parse(match.group(3)!),
  );
}

DateTime? _parseTime(String? value) {
  final raw = value?.trim() ?? '';
  if (raw.isEmpty) return null;
  final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(raw);
  if (match == null) return null;
  return DateTime(
    2000,
    1,
    1,
    int.parse(match.group(1)!),
    int.parse(match.group(2)!),
  );
}

String _formatDate(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${value.year}-${two(value.month)}-${two(value.day)}';
}

String _formatTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.hour)}:${two(value.minute)}';
}

String? _readString(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final raw = profile[key];
    if (raw == null) continue;
    final text = raw.toString().trim();
    if (text.isNotEmpty) return text;
  }
  return null;
}

String? _readText(Map<String, dynamic> map, String key) {
  final raw = map[key];
  if (raw == null) return null;
  final text = raw.toString().trim();
  return text.isEmpty ? null : text;
}

double? _readDouble(Map<String, dynamic> profile, List<String> keys) {
  for (final key in keys) {
    final raw = profile[key];
    if (raw is num) return raw.toDouble();
    final parsed = double.tryParse((raw ?? '').toString());
    if (parsed != null) return parsed;
  }
  return null;
}

List<dynamic> _list(dynamic value) =>
    value is List<dynamic> ? value : const <dynamic>[];

Map<String, dynamic> _map(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

String _routeModeLabel(AstroChartRouteMode mode) {
  switch (mode) {
    case AstroChartRouteMode.standard:
      return '标准路线';
    case AstroChartRouteMode.classical:
      return '古典路线';
    case AstroChartRouteMode.modern:
      return '现代路线';
  }
}

String _routeModeLabelText(String mode) {
  switch (mode) {
    case 'standard':
      return '标准路线';
    case 'classical':
      return '古典路线';
    case 'modern':
      return '现代路线';
    default:
      return mode;
  }
}



