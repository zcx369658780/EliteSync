import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/match_mock.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_countdown_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_detail_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_result_dto.dart';

class MatchRemoteDataSource {
  MatchRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;
  int? _cachedMatchId;

  Future<Map<String, dynamic>> _currentMatchRaw() async {
    final result = await apiClient.get('/api/v1/match/current');
    if (result is NetworkSuccess<Map<String, dynamic>>) {
      final matchId = (result.data['match_id'] as num?)?.toInt();
      if (matchId != null && matchId > 0) {
        _cachedMatchId = matchId;
      }
      return result.data;
    }
    final failure = result as NetworkFailure<Map<String, dynamic>>;
    throw Exception(failure.message);
  }

  Future<MatchCountdownDto> getCountdown() async {
    if (useMock) return MatchCountdownDto.fromJson(MatchMock.countdown);
    // Backend has no dedicated countdown endpoint; if current match exists, treat as ready.
    final current = await _currentMatchRaw();
    return MatchCountdownDto.fromJson({
      'status': 'ready',
      'reveal_at': DateTime.now().toIso8601String(),
      'hint': (current['highlights'] as String?) ?? '匹配已揭晓',
    });
  }

  Future<MatchResultDto> getResult() async {
    if (useMock) return MatchResultDto.fromJson(MatchMock.resultHappy);
    final raw = await _currentMatchRaw();
    final tags = (raw['explanation_tags'] as List<dynamic>? ?? const [])
        .map((e) => _formatTag(e.toString()))
        .where((e) => e.isNotEmpty)
        .toList();
    final core = (raw['core_scores'] as Map<String, dynamic>? ?? const {});
    final astro = (raw['astro_scores'] as Map<String, dynamic>? ?? const {});
    final reasons = (raw['match_reasons'] as Map<String, dynamic>? ?? const {});
    final reasonMatch = (reasons['match'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .take(3)
        .map((e) => {
              'title': _moduleName((e['module'] ?? '匹配项').toString()),
              'value': (e['score'] as num?)?.toInt() ?? 0,
              'desc': (e['reason'] ?? '').toString(),
            })
        .toList();
    final generatedHighlights = reasonMatch.isNotEmpty
        ? reasonMatch
        : <Map<String, dynamic>>[
            {
              'title': '人格维度',
              'value': (core['personality'] as num?)?.toInt() ?? 0,
              'desc': '问卷人格维度匹配',
            },
            {
              'title': 'MBTI',
              'value': (core['mbti'] as num?)?.toInt() ?? 0,
              'desc': 'MBTI 互补度',
            },
            {
              'title': '玄学综合',
              'value': (core['astro'] as num?)?.toInt() ?? 0,
              'desc': '八字/属相/星座/星盘综合',
            },
          ];
    return MatchResultDto.fromJson({
      'status': (raw['match_verdict'] ?? 'unknown').toString(),
      'headline': (raw['highlights'] ?? '综合匹配结果').toString(),
      'score': (raw['final_score'] as num?)?.toInt() ?? 0,
      'tags': tags,
      'highlights': generatedHighlights,
      'astro_scores': astro,
    });
  }

  Future<MatchDetailDto> getDetail() async {
    if (useMock) {
      return const MatchDetailDto(
        reasons: ['沟通风格互补', '关系目标一致', '同城活动便利'],
        weights: {'八字': 50, '属相': 30, '星座': 10, '星盘': 10},
      );
    }
    final raw = await _currentMatchRaw();
    final reasons = (raw['match_reasons'] as Map<String, dynamic>? ?? const {});
    final match = (reasons['match'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) {
          final module = _moduleName((e['module'] ?? '').toString());
          final score = (e['score'] as num?)?.toInt();
          final reason = (e['reason'] ?? '').toString();
          final scorePart = score == null ? '' : '（$score分）';
          return '[匹配] $module$scorePart：$reason'.trim();
        })
        .where((e) => e.isNotEmpty)
        .toList();
    final mismatch = (reasons['mismatch'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((e) {
          final module = _moduleName((e['module'] ?? '').toString());
          final score = (e['score'] as num?)?.toInt();
          final reason = (e['reason'] ?? '').toString();
          final scorePart = score == null ? '' : '（$score分）';
          return '[风险] $module$scorePart：$reason'.trim();
        })
        .where((e) => e.isNotEmpty)
        .toList();
    final detailReasons = <String>[
      ...match,
      ...mismatch,
    ];
    final defaultReasons = <String>[
      '综合匹配分: ${raw['final_score'] ?? 0}',
      '匹配结论: ${(raw['match_verdict'] ?? '待评估').toString()}',
    ];
    return MatchDetailDto.fromJson({
      'reasons': detailReasons.isNotEmpty ? detailReasons : defaultReasons,
      'weights': const {
        '八字': 50,
        '属相': 30,
        '星座': 10,
        '星盘': 10,
      },
    });
  }

  Future<void> submitIntention(String action) async {
    if (useMock) return;
    final raw = await _currentMatchRaw();
    final matchId = _cachedMatchId ?? (raw['match_id'] as num?)?.toInt();
    if (matchId == null || matchId <= 0) {
      throw Exception('match id not found');
    }
    final like = action == 'accept';
    final result = await apiClient.post(
      '/api/v1/match/like',
      body: {
        'match_id': matchId,
        'like': like,
      },
    );
    if (result is NetworkFailure<Map<String, dynamic>>) {
      throw Exception(result.message);
    }
  }

  String _moduleName(String raw) {
    final key = raw.trim().toLowerCase();
    switch (key) {
      case 'bazi':
      case 'bazimatch':
        return '八字';
      case 'zodiac':
        return '属相';
      case 'constellation':
        return '星座';
      case 'natal_chart':
      case 'natalchart':
      case 'astrology':
        return '星盘';
      case 'mbti':
        return 'MBTI';
      case 'personality':
      case 'questionnaire':
        return '性格问卷';
      case 'city':
      case 'same_city':
        return '同城';
      case 'age':
      case 'age_gap':
        return '年龄差';
      case 'communication':
        return '沟通节奏';
      default:
        return raw.isEmpty ? '匹配项' : raw;
    }
  }

  String _formatTag(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (v.contains('=')) {
      final parts = v.split('=');
      final k = parts.first.trim();
      final val = parts.length > 1 ? parts.sublist(1).join('=').trim() : '';
      return '${_moduleName(k)}因子 $val';
    }
    return _moduleName(v);
  }
}
