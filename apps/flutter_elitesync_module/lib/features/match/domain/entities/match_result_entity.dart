import 'package:flutter_elitesync_module/features/match/domain/entities/match_highlight_entity.dart';

class MatchResultEntity {
  const MatchResultEntity({
    required this.headline,
    required this.score,
    required this.tags,
    required this.highlights,
    this.matchId,
    this.partnerId,
  });
  final String headline;
  final int score;
  final List<String> tags;
  final List<MatchHighlightEntity> highlights;
  final int? matchId;
  final int? partnerId;
}
