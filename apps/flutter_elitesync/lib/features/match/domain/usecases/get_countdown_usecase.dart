import 'package:flutter_elitesync/features/match/domain/entities/match_countdown_entity.dart';
import 'package:flutter_elitesync/features/match/domain/repository/match_repository.dart';

class GetCountdownUseCase {
  const GetCountdownUseCase(this.repository);
  final MatchRepository repository;
  Future<MatchCountdownEntity> call() => repository.getCountdown();
}
