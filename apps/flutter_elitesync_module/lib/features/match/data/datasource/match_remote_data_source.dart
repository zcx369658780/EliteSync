import 'dart:async';

import 'package:flutter_elitesync_module/core/network/api_client.dart';
import 'package:flutter_elitesync_module/core/network/network_result.dart';
import 'package:flutter_elitesync_module/mocks/mock_data/match_mock.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_countdown_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_detail_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_result_dto.dart';

class MatchRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 6);

  MatchRemoteDataSource({required this.apiClient, required this.useMock});

  final ApiClient apiClient;
  final bool useMock;
  int? _cachedMatchId;
  int? _cachedPartnerId;
  Map<String, dynamic>? _cachedDetailRaw;
  final Map<int, _ExplanationCacheEntry> _explanationCache =
      <int, _ExplanationCacheEntry>{};
  static const Duration _explanationCacheTtl = Duration(seconds: 45);

  DateTime _nextDropAtLocal() {
    final now = DateTime.now().toLocal();
    final todayAt21 = DateTime(now.year, now.month, now.day, 21);
    if (now.isBefore(todayAt21)) {
      return todayAt21;
    }
    return DateTime(now.year, now.month, now.day + 1, 21);
  }

  String _formatDateTimeLabel(DateTime value) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${value.month}月${two(value.day)}日 ${two(value.hour)}:${two(value.minute)}';
  }

  String _formatDropHint(DateTime revealAt) {
    final now = DateTime.now().toLocal();
    final sameDay =
        now.year == revealAt.year &&
        now.month == revealAt.month &&
        now.day == revealAt.day;
    if (sameDay) {
      return '预计今晚 ${revealAt.hour.toString().padLeft(2, '0')}:${revealAt.minute.toString().padLeft(2, '0')} 揭晓';
    }
    return '预计 ${_formatDateTimeLabel(revealAt)} 揭晓';
  }

  Future<Map<String, dynamic>> _currentMatchRaw() async {
    final paths = <String>['/api/v1/matches/current', '/api/v1/match/current'];
    NetworkFailure<Map<String, dynamic>>? lastFailure;
    for (final path in paths) {
      final result = await apiClient.get(path).timeout(_requestTimeout);
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final matchId = (result.data['match_id'] as num?)?.toInt();
        final partnerId = (result.data['partner_id'] as num?)?.toInt();
        if (matchId != null && matchId > 0) {
          _cachedMatchId = matchId;
        }
        if (partnerId != null && partnerId > 0) {
          _cachedPartnerId = partnerId;
        }
        _cachedDetailRaw = result.data;
        return result.data;
      }
      lastFailure = result as NetworkFailure<Map<String, dynamic>>;
    }
    final failure =
        lastFailure ??
        const NetworkFailure<Map<String, dynamic>>(message: 'Request failed');
    throw MatchRemoteException(
      message: failure.message,
      statusCode: failure.statusCode,
      code: failure.code,
    );
  }

  bool _isCacheValid(_ExplanationCacheEntry entry) {
    return DateTime.now().difference(entry.cachedAt) <= _explanationCacheTtl;
  }

  Future<Map<String, dynamic>?> _loadExplanationRawByTarget(
    int targetUserId,
  ) async {
    final cached = _explanationCache[targetUserId];
    if (cached != null && _isCacheValid(cached)) {
      return cached.data;
    }

    final paths = <String>[
      '/api/v1/matches/$targetUserId/explanation',
      '/api/v1/match/$targetUserId/explanation',
    ];

    for (final path in paths) {
      final result = await apiClient.get(path).timeout(_requestTimeout);
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        final data = result.data;
        _explanationCache[targetUserId] = _ExplanationCacheEntry(
          data: data,
          cachedAt: DateTime.now(),
        );
        final matchId = (data['match_id'] as num?)?.toInt();
        if (matchId != null && matchId > 0) {
          _cachedMatchId = matchId;
        }
        _cachedDetailRaw = data;
        return data;
      }
    }
    return null;
  }

  Future<Map<String, dynamic>> _detailRawPreferExplanation() async {
    Map<String, dynamic> current;
    try {
      current = await _currentMatchRaw();
    } catch (_) {
      final fallback = _cachedDetailRaw;
      if (fallback != null && fallback.isNotEmpty) {
        return fallback;
      }
      rethrow;
    }
    final targetUserId =
        _cachedPartnerId ?? (current['partner_id'] as num?)?.toInt();
    if (targetUserId != null && targetUserId > 0) {
      final explanation = await _loadExplanationRawByTarget(targetUserId);
      if (explanation != null && explanation.isNotEmpty) {
        return explanation;
      }
    }
    return current;
  }

  Future<MatchCountdownDto> getCountdown() async {
    if (useMock) return MatchCountdownDto.fromJson(MatchMock.countdown);
    try {
      final current = await _currentMatchRaw();
      final released = (current['drop_released'] as bool?) ?? true;
      final revealAt = DateTime.now().toLocal();
      return MatchCountdownDto.fromJson({
        'status': released ? 'drop_open' : 'waiting_drop',
        'reveal_at': revealAt.toIso8601String(),
        'hint': released
            ? (current['highlights'] as String?) ?? '本周匹配已揭晓，点击查看悬念版结果。'
            : '本周匹配正在准备中，请稍后回来查看。',
      });
    } on MatchRemoteException catch (e) {
      if (e.statusCode == 404) {
        final revealAt = _nextDropAtLocal();
        return MatchCountdownDto.fromJson({
          'status': 'waiting_drop',
          'reveal_at': revealAt.toIso8601String(),
          'hint': _formatDropHint(revealAt),
        });
      }
      rethrow;
    }
  }

  Future<MatchResultDto> getResult() async {
    if (useMock) return MatchResultDto.fromJson(MatchMock.resultHappy);
    final raw = await _currentMatchRaw();
    final tags = _asList(
      raw['explanation_tags'],
    ).map((e) => _formatTag(e.toString())).where((e) => e.isNotEmpty).toList();
    final core = _asMap(raw['core_scores']);
    final astro = _asMap(raw['astro_scores']);
    final reasons = _asMap(raw['match_reasons']);
    final reasonMatch = _toListOfMap(reasons['match'])
        .take(3)
        .map(
          (e) => {
            'title': _moduleName((e['module'] ?? '匹配项').toString()),
            'value': (e['score'] as num?)?.toInt() ?? 0,
            'desc': (e['reason'] ?? '').toString(),
          },
        )
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
              'title': '性格（已关闭）',
              'value': (core['mbti'] as num?)?.toInt() ?? 0,
              'desc': '历史性格结果已关闭，不再参与排序',
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
      'match_id': (raw['match_id'] as num?)?.toInt(),
      'partner_id': (raw['partner_id'] as num?)?.toInt(),
    });
  }

  Future<MatchDetailDto> getDetail() async {
    if (useMock) {
      return const MatchDetailDto(
        reasons: ['沟通风格互补', '关系目标一致', '同城活动便利'],
        weights: {'八字': 50, '属相': 30, '星座': 10, '星盘': 10},
        moduleScores: {'八字': 78, '属相': 81, '星座': 73, '星盘': 75},
        moduleInsights: ['八字：五行互补中等偏上，生活节奏较易协调'],
      );
    }
    final raw = await _detailRawPreferExplanation();
    final reasons = _asMap(raw['match_reasons']);
    final reasonGlossary = _asMap(
      reasons['reason_glossary'],
    ).map((k, v) => MapEntry(k.toString(), v.toString()));
    final evidenceStrengthSummary = _asMap(
      reasons['evidence_strength_summary'],
    );
    final serverCompatibilitySections = _asMap(
      reasons['compatibility_sections'],
    ).map((k, v) => MapEntry(k.toString(), _toListOfMap(v)));
    final astroScoresRaw = _asMap(raw['astro_scores']);
    final match = _toListOfMap(reasons['match'])
        .map((e) {
          final module = _moduleName((e['module'] ?? '').toString());
          final score = (e['score'] as num?)?.toInt();
          final reason = (e['reason'] ?? '').toString();
          final scorePart = score == null ? '' : '（$score分）';
          return '匹配亮点｜$module$scorePart：$reason'.trim();
        })
        .where((e) => e.isNotEmpty)
        .toList();
    final mismatch = _toListOfMap(reasons['mismatch'])
        .map((e) {
          final module = _moduleName((e['module'] ?? '').toString());
          final score = (e['score'] as num?)?.toInt();
          final reason = (e['reason'] ?? '').toString();
          final scorePart = score == null ? '' : '（$score分）';
          return '需要留意｜$module$scorePart：$reason'.trim();
        })
        .where((e) => e.isNotEmpty)
        .toList();
    final detailReasons = <String>[...match, ...mismatch];
    final modules = _toListOfMap(reasons['modules']);
    final serverModuleExplanations =
        _toListOfMap(reasons['module_explanations']).map((row) {
          final tags = _asList(
            row['tags'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final coreTags = _asList(
            row['core_tags'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final auxTags = _asList(
            row['aux_tags'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final coreTagExplains = _asMap(
            row['core_tag_explains'],
          ).map((k, v) => MapEntry(k.toString(), v.toString()));
          final auxTagExplains = _asMap(
            row['aux_tag_explains'],
          ).map((k, v) => MapEntry(k.toString(), v.toString()));
          final coreTagRefs = _asMap(
            row['core_tag_refs'],
          ).map((k, v) => MapEntry(k.toString(), v.toString()));
          final auxTagRefs = _asMap(
            row['aux_tag_refs'],
          ).map((k, v) => MapEntry(k.toString(), v.toString()));
          final confidence = (row['confidence'] as num?)?.toDouble() ?? 0.5;
          final degraded = (row['degraded'] as bool?) ?? false;
          final tierRaw = (row['confidence_tier'] ?? '')
              .toString()
              .trim()
              .toLowerCase();
          final confidenceTier = tierRaw.isNotEmpty
              ? tierRaw
              : (degraded
                    ? 'low'
                    : (confidence >= 0.8
                          ? 'high'
                          : (confidence >= 0.6 ? 'medium' : 'low')));
          final degradeReason = (row['degrade_reason'] ?? '').toString().trim();
          final priority = (row['priority'] as num?)?.toInt() ?? 0;
          final priorityLevel = (row['priority_level'] ?? '').toString().trim();
          final priorityReason = (row['priority_reason'] ?? '')
              .toString()
              .trim();
          final evidenceStrength = (row['evidence_strength'] ?? '')
              .toString()
              .trim();
          final evidenceStrengthReason = (row['evidence_strength_reason'] ?? '')
              .toString()
              .trim();
          if (coreTags.isEmpty && auxTags.isEmpty && tags.isNotEmpty) {
            final guessedCore = tags
                .where(
                  (e) =>
                      e.contains('六合') ||
                      e.contains('三合') ||
                      e.contains('相冲') ||
                      e.contains('相刑') ||
                      e.contains('相害') ||
                      e.contains('五行') ||
                      e.contains('八字') ||
                      e.contains('合盘') ||
                      e.contains('星盘') ||
                      e.contains('MBTI'),
                )
                .toList();
            final guessedAux = tags
                .where((e) => !guessedCore.contains(e))
                .toList();
            return {
              ...row,
              'core_tags': guessedCore,
              'aux_tags': guessedAux,
              'core_tag_explains': coreTagExplains,
              'aux_tag_explains': auxTagExplains,
              'core_tag_refs': coreTagRefs,
              'aux_tag_refs': auxTagRefs,
              'confidence': confidence,
              'confidence_tier': confidenceTier,
              'degraded': degraded,
              'degrade_reason': degradeReason,
              'priority': priority,
              'priority_level': priorityLevel,
              'priority_reason': priorityReason,
              'evidence_strength': evidenceStrength,
              'evidence_strength_reason': evidenceStrengthReason,
            };
          }
          return {
            ...row,
            'core_tags': coreTags,
            'aux_tags': auxTags,
            'core_tag_explains': coreTagExplains,
            'aux_tag_explains': auxTagExplains,
            'core_tag_refs': coreTagRefs,
            'aux_tag_refs': auxTagRefs,
            'confidence': confidence,
            'confidence_tier': confidenceTier,
            'degraded': degraded,
            'degrade_reason': degradeReason,
            'priority': priority,
            'priority_level': priorityLevel,
            'priority_reason': priorityReason,
            'evidence_strength': evidenceStrength,
            'evidence_strength_reason': evidenceStrengthReason,
          };
        }).toList();
    final serverExplanationBlocks = _toListOfMap(reasons['explanation_blocks'])
        .map((row) {
          final process = _asList(
            row['process'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final risks = _asList(
            row['risks'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final advice = _asList(
            row['advice'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final coreEvidence = _asList(
            row['core_evidence'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          final supportingEvidence = _asList(
            row['supporting_evidence'],
          ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
          return {
            ...row,
            'summary': (row['summary'] ?? '').toString().trim(),
            'process': process,
            'risks': risks,
            'advice': advice,
            'core_evidence': coreEvidence,
            'supporting_evidence': supportingEvidence,
            'confidence': (row['confidence'] ?? '').toString().trim(),
            'priority': (row['priority'] ?? '').toString().trim(),
          };
        })
        .toList();
    final moduleScores = <String, int>{};
    final moduleInsights = <String>[];
    final moduleExplanations = <Map<String, dynamic>>[
      ...serverModuleExplanations.map((e) => Map<String, dynamic>.from(e)),
    ];
    final compatibilitySections = <String, List<Map<String, dynamic>>>{
      'natal_compatibility': <Map<String, dynamic>>[],
      'synastry': <Map<String, dynamic>>[],
      'composite_like': <Map<String, dynamic>>[],
      ...serverCompatibilitySections,
    };
    final moduleWeights = <String, int>{};
    for (final m in modules) {
      final label = (m['label'] ?? '').toString().trim().isNotEmpty
          ? (m['label'] ?? '').toString().trim()
          : _moduleName((m['key'] ?? '').toString());
      final score = (m['score'] as num?)?.toInt() ?? 0;
      final confidence = (m['confidence'] as num?)?.toDouble() ?? 0.5;
      final degraded = (m['degraded'] as bool?) ?? false;
      final degradeReason = (m['degrade_reason'] ?? '').toString().trim();
      moduleScores[label] = score;
      final weightPct = ((m['weight'] as num?)?.toDouble() ?? 0) * 100;
      if (weightPct > 0) {
        moduleWeights[label] = weightPct.round();
      }

      final reasonShort = (m['reason_short'] ?? '').toString().trim();
      final reasonDetail = (m['reason_detail'] ?? '').toString().trim();
      final riskShort = (m['risk_short'] ?? '').toString().trim();
      final riskLevelRaw = (m['risk_level'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final labelTags = _asList(
        m['evidence_tag_labels'],
      ).map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      final tags = labelTags.isNotEmpty
          ? labelTags
          : _asList(m['evidence_tags'])
                .map((e) => _formatEvidenceTag(e.toString()))
                .where((e) => e.isNotEmpty)
                .toList();
      final mainExplain = reasonDetail.isNotEmpty
          ? reasonDetail
          : (reasonShort.isNotEmpty ? reasonShort : '暂无解释');
      final riskExplain = riskShort.isNotEmpty ? '；风险提示：$riskShort' : '';
      final tagExplain = tags.isNotEmpty ? '；证据标签：${tags.join("、")}' : '';
      moduleInsights.add('$label（$score分）：$mainExplain$riskExplain$tagExplain');
      final riskLevel = riskLevelRaw.isNotEmpty
          ? riskLevelRaw
          : (score < 60
                ? 'high'
                : ((riskShort.isNotEmpty || score < 70) ? 'medium' : 'low'));
      final riskWeight = riskLevel == 'high'
          ? 300
          : (riskLevel == 'medium' ? 200 : 100);
      final degradedWeight = degraded ? 30 : 0;
      final lowConfidenceWeight = ((1.0 - confidence.clamp(0.0, 1.0)) * 80)
          .round();
      final lowScoreWeight = ((100 - score.clamp(0, 100)) * 0.6).round();
      final priority =
          riskWeight + degradedWeight + lowConfidenceWeight + lowScoreWeight;
      final priorityLevel = priority >= 300
          ? 'high'
          : (priority >= 220 ? 'medium' : 'normal');
      final priorityReason = [
        if (riskLevel == 'high')
          '风险等级高'
        else if (riskLevel == 'medium')
          '风险等级中',
        if (degraded) '存在降级估算',
        if (confidence < 0.6) '置信度偏低',
        if (score < 60) '分项得分偏低',
      ].join('、');
      final coreTags = tags
          .where(
            (e) =>
                e.contains('六合') ||
                e.contains('三合') ||
                e.contains('相冲') ||
                e.contains('相刑') ||
                e.contains('相害') ||
                e.contains('五行') ||
                e.contains('八字') ||
                e.contains('合盘') ||
                e.contains('星盘') ||
                e.contains('MBTI'),
          )
          .toList();
      final auxTags = tags.where((e) => !coreTags.contains(e)).toList();
      var evidenceScore = 0;
      if (coreTags.length >= 2) {
        evidenceScore += 2;
      } else if (coreTags.length == 1) {
        evidenceScore += 1;
      } else {
        evidenceScore -= 1;
      }
      if (auxTags.length >= 2) evidenceScore += 1;
      if (confidence >= 0.8) {
        evidenceScore += 1;
      } else if (confidence < 0.6) {
        evidenceScore -= 1;
      }
      if (degraded) evidenceScore -= 1;
      final evidenceStrength = evidenceScore >= 3
          ? 'high'
          : (evidenceScore >= 1 ? 'medium' : 'low');
      final evidenceStrengthReason = [
        if (coreTags.length >= 2)
          '核心证据充足'
        else if (coreTags.length == 1)
          '具备核心证据'
        else
          '核心证据不足',
        if (auxTags.length >= 2) '辅助证据较多' else if (auxTags.isEmpty) '辅助证据较少',
        if (confidence >= 0.8) '置信度高' else if (confidence < 0.6) '置信度偏低',
        if (degraded) '存在降级估算',
      ].join('、');
      if (serverModuleExplanations.isEmpty) {
        moduleExplanations.add({
          'label': label,
          'score': score,
          'confidence': confidence,
          'confidence_tier': degraded
              ? 'low'
              : (confidence >= 0.8
                    ? 'high'
                    : (confidence >= 0.6 ? 'medium' : 'low')),
          'degraded': degraded,
          'degrade_reason': degradeReason,
          'reason': mainExplain,
          'risk': riskShort,
          'risk_level': riskLevel,
          'priority': priority,
          'priority_level': priorityLevel,
          'priority_reason': priorityReason.isEmpty
              ? '当前为常规关注项'
              : priorityReason,
          'tags': tags,
          'core_tags': coreTags,
          'aux_tags': auxTags,
          'core_tag_explains': const <String, String>{},
          'aux_tag_explains': const <String, String>{},
          'core_tag_refs': const <String, String>{},
          'aux_tag_refs': const <String, String>{},
          'evidence_strength': evidenceStrength,
          'evidence_strength_reason': evidenceStrengthReason,
        });
      }
    }
    if (serverCompatibilitySections.isEmpty && moduleExplanations.isNotEmpty) {
      for (final row in moduleExplanations) {
        final label = (row['label'] ?? '').toString().trim();
        if (label == '八字' || label == '属相') {
          compatibilitySections['natal_compatibility']!.add(row);
          continue;
        }
        if (label == '男女合盘' || label == '合盘') {
          compatibilitySections['composite_like']!.add(row);
          continue;
        }
        compatibilitySections['synastry']!.add(row);
      }
    }
    if (moduleScores.isEmpty && astroScoresRaw.isNotEmpty) {
      final fallback = <String, int>{};
      astroScoresRaw.forEach((k, v) {
        fallback[_moduleName(k)] = (v as num?)?.toInt() ?? 0;
      });
      moduleScores.addAll(fallback);
    }
    if (moduleInsights.isEmpty && moduleScores.isNotEmpty) {
      moduleInsights.addAll(
        moduleScores.entries.map(
          (e) => '${e.key}（${e.value}分）：该分项已纳入当前结论，建议结合“亮点、风险与证据标签”综合判断。',
        ),
      );
    }
    final defaultReasons = <String>[
      '综合匹配分: ${raw['final_score'] ?? 0}',
      '匹配结论: ${(raw['match_verdict'] ?? '待评估').toString()}',
    ];
    return MatchDetailDto.fromJson({
      'reasons': detailReasons.isNotEmpty ? detailReasons : defaultReasons,
      'weights': moduleWeights.isNotEmpty
          ? moduleWeights
          : const {'八字': 50, '属相': 30, '星座': 10, '星盘': 10},
      'module_scores': moduleScores,
      'module_insights': moduleInsights,
      'module_explanations': moduleExplanations,
      'explanation_blocks': serverExplanationBlocks,
      'compatibility_sections': compatibilitySections,
      'reason_glossary': reasonGlossary,
      'evidence_strength_summary': evidenceStrengthSummary,
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
    final paths = <String>['/api/v1/matches/confirm', '/api/v1/match/like'];
    NetworkFailure<Map<String, dynamic>>? lastFailure;
    for (final path in paths) {
      final result = await apiClient.post(
        path,
        body: {'match_id': matchId, 'like': like},
      );
      if (result is NetworkSuccess<Map<String, dynamic>>) {
        return;
      }
      lastFailure = result as NetworkFailure<Map<String, dynamic>>;
      final status = lastFailure.statusCode ?? 0;
      if (status == 404 || status == 405) {
        continue;
      }
      break;
    }
    if (lastFailure != null) {
      throw Exception(lastFailure.message);
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
        return '性格（已关闭）';
      case 'personality':
      case 'questionnaire':
        return '性格';
      case 'ziwei':
        return '紫微斗数';
      case 'life_palace':
        return '命宫';
      case 'body_palace':
        return '身宫';
      case 'major_themes':
        return '主题倾向';
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

  String _formatEvidenceTag(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return '';
    if (!v.contains('=')) {
      const tagMap = <String, String>{
        'wu_xing_complement': '五行互补',
        'long_term_harmony_oriented': '长期协同倾向',
        'bazi_similarity_estimation': '八字结构估算',
        'confidence_medium': '中等置信度',
        'bazi_degraded_estimation': '八字降级估算',
        'missing_bazi': '缺少八字信息',
        'zodiac_liuhe': '属相六合',
        'zodiac_sanhe': '属相三合',
        'zodiac_same': '同属相',
        'zodiac_chong': '属相相冲',
        'zodiac_xing': '属相相刑',
        'zodiac_hai': '属相相害',
        'zodiac_normal': '属相常规关系',
        'missing_zodiac': '缺少属相信息',
        'same_element': '同元素星座',
        'element_complement': '元素互补',
        'element_tension': '元素张力',
        'process_layer_signal': '过程层信号',
        'missing_constellation': '缺少星座信息',
        'natal_chart_partial_data': '星盘数据不完整',
        'moon_sync_high': '情绪同步高',
        'moon_sync_low': '情绪同步低',
        'asc_style_match': '表达风格匹配',
        'asc_style_gap': '表达风格差异',
        'sun_direction_sync': '关系方向同步',
        'sun_direction_gap': '关系方向差异',
        'pair_chart_v1': '合盘基础模型',
        'pair_chart_harmony': '合盘协同性高',
        'pair_chart_tension': '合盘张力偏高',
        'pair_chart_degraded': '合盘降级估算',
        'sun_moon_harmony': '日月互动',
        'emotion_rhythm': '情绪节奏',
        'mbti_lite_low_confidence': '性格低置信度',
        'missing_mbti': '缺少性格结果',
        'profile_similarity_high': '人格相似度高',
        'bidirectional_acceptance_high': '双向接受度高',
        'key_dimension_gap_high': '关键维度差距高',
        'missing_personality_vector': '缺少人格向量',
        'ziwei_canonical': '紫微 canonical',
        'ziwei_long_term_profile': '紫微持久画像',
        'ziwei_degraded_estimation': '紫微降级估算',
        'missing_ziwei': '缺少紫微画像',
        'life_palace_aligned': '命宫一致',
        'body_palace_aligned': '身宫一致',
        'major_themes_overlap': '主题倾向重叠',
      };
      return tagMap[v.toLowerCase()] ?? _moduleName(v);
    }

    final parts = v.split('=');
    final key = parts.first.trim().toLowerCase();
    final value = parts.length > 1 ? parts.sublist(1).join('=').trim() : '';

    switch (key) {
      case 'same_city_boost':
        return '同城加权 $value';
      case 'age_gap_adjustment':
        return '年龄差修正 $value';
      case 'mbti_letter_match':
        return '性格协同 $value';
      case 'communication_mismatch':
        return '沟通磨合系数 $value';
      case 'ziwei_alignment':
        return '紫微协同性 $value';
      case 'relation_type':
        {
          const relationMap = <String, String>{
            'liuhe': '六合',
            'sanhe': '三合',
            'same': '同属相',
            'chong': '相冲',
            'xing': '相刑',
            'hai': '相害',
            'normal': '常规关系',
          };
          final label = relationMap[value.toLowerCase()] ?? value;
          return '属相关系 $label';
        }
      default:
        return '${_moduleName(key)} $value'.trim();
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((key, val) => MapEntry(key.toString(), val));
    }
    return <String, dynamic>{};
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List<dynamic>) return value;
    if (value is List) return List<dynamic>.from(value);
    return const <dynamic>[];
  }

  List<Map<String, dynamic>> _toListOfMap(dynamic value) {
    return _asList(value).map(_asMap).where((e) => e.isNotEmpty).toList();
  }
}

class MatchRemoteException implements Exception {
  MatchRemoteException({required this.message, this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() {
    final parts = <String>[message];
    if (statusCode != null) parts.add('statusCode=$statusCode');
    if (code != null && code!.isNotEmpty) parts.add('code=$code');
    return parts.join(' ');
  }
}

class _ExplanationCacheEntry {
  const _ExplanationCacheEntry({required this.data, required this.cachedAt});

  final Map<String, dynamic> data;
  final DateTime cachedAt;
}
