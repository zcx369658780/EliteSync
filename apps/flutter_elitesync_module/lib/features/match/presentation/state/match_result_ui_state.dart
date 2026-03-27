import 'package:flutter_elitesync_module/features/match/domain/entities/match_result_entity.dart';

class MatchResultUiState {
  const MatchResultUiState({this.data, this.error});
  final MatchResultEntity? data;
  final String? error;
}
