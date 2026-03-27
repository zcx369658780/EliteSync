import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/data/mapper/match_mapper.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_countdown_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/repository/match_repository.dart';

class MatchRepositoryImpl implements MatchRepository {
  const MatchRepositoryImpl({required this.remote, required this.mapper});

  final MatchRemoteDataSource remote;
  final MatchMapper mapper;

  @override
  Future<MatchCountdownEntity> getCountdown() async => mapper.countdown(await remote.getCountdown());

  @override
  Future<MatchDetailEntity> getDetail() async => mapper.detail(await remote.getDetail());

  @override
  Future<MatchResultEntity> getResult() async => mapper.result(await remote.getResult());

  @override
  Future<void> submitIntention(String action) => remote.submitIntention(action);
}
