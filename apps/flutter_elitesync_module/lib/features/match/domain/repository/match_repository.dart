import 'package:flutter_elitesync_module/features/match/domain/entities/match_countdown_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';

abstract class MatchRepository {
  Future<MatchCountdownEntity> getCountdown();
  Future<MatchResultEntity> getResult();
  Future<MatchDetailEntity> getDetail();
  Future<void> submitIntention(String action);
}
