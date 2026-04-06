import 'package:flutter_elitesync_module/features/match/data/dto/match_countdown_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_detail_dto.dart';
import 'package:flutter_elitesync_module/features/match/data/dto/match_result_dto.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_countdown_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';

class MatchMapper {
  const MatchMapper();

  MatchCountdownEntity countdown(MatchCountdownDto dto) => MatchCountdownEntity(
    status: dto.status,
    revealAt: DateTime.tryParse(dto.revealAt),
    hint: dto.hint,
  );

  MatchResultEntity result(MatchResultDto dto) => MatchResultEntity(
    headline: dto.headline,
    score: dto.score,
    tags: dto.tags,
    highlights: dto.highlights
        .map(
          (e) => MatchHighlightEntity(
            title: (e['title'] ?? '').toString(),
            value: (e['value'] as num?)?.toInt() ?? 0,
            desc: (e['desc'] ?? '').toString(),
          ),
        )
        .toList(),
  );

  MatchDetailEntity detail(MatchDetailDto dto) => MatchDetailEntity(
    reasons: dto.reasons,
    weights: dto.weights,
    moduleScores: dto.moduleScores,
    moduleInsights: dto.moduleInsights,
    moduleExplanations: dto.moduleExplanations,
    explanationBlocks: dto.explanationBlocks,
    compatibilitySections: dto.compatibilitySections,
    reasonGlossary: dto.reasonGlossary,
    evidenceStrengthSummary: dto.evidenceStrengthSummary,
  );
}
