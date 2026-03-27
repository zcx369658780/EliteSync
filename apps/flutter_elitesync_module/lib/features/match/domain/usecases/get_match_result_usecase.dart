import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync_module/features/match/domain/repository/match_repository.dart';

class GetMatchResultUseCase {
  const GetMatchResultUseCase(this.repository);
  final MatchRepository repository;
  Future<MatchResultEntity> call() => repository.getResult();
}
