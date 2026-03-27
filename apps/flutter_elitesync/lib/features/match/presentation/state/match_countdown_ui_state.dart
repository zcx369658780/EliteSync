import 'package:flutter_elitesync/features/match/domain/entities/match_countdown_entity.dart';

class MatchCountdownUiState {
  const MatchCountdownUiState({this.data, this.error});
  final MatchCountdownEntity? data;
  final String? error;
}
