import 'package:flutter_elitesync/features/match/domain/repository/match_repository.dart';

class SubmitIntentionUseCase {
  const SubmitIntentionUseCase(this.repository);
  final MatchRepository repository;
  Future<void> call(String action) => repository.submitIntention(action);
}
