import 'package:flutter_elitesync/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync/features/match/domain/repository/match_repository.dart';

class GetMatchDetailUseCase {
  const GetMatchDetailUseCase(this.repository);
  final MatchRepository repository;
  Future<MatchDetailEntity> call() => repository.getDetail();
}
