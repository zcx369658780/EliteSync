import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/match/data/datasource/match_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/match/data/mapper/match_mapper.dart';
import 'package:flutter_elitesync_module/features/match/data/repository/match_repository_impl.dart';
import 'package:flutter_elitesync_module/features/match/domain/repository/match_repository.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_countdown_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_match_result_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/get_match_detail_usecase.dart';
import 'package:flutter_elitesync_module/features/match/domain/usecases/submit_intention_usecase.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_countdown_ui_state.dart';
import 'package:flutter_elitesync_module/features/match/presentation/state/match_result_ui_state.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final matchRemoteDataSourceProvider = Provider<MatchRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return MatchRemoteDataSource(apiClient: ref.watch(apiClientProvider), useMock: env.useMockMatch);
});

final matchRepositoryProvider = Provider<MatchRepository>((ref) {
  return MatchRepositoryImpl(remote: ref.watch(matchRemoteDataSourceProvider), mapper: const MatchMapper());
});

final getCountdownUseCaseProvider = Provider<GetCountdownUseCase>((ref) => GetCountdownUseCase(ref.watch(matchRepositoryProvider)));
final getMatchResultUseCaseProvider = Provider<GetMatchResultUseCase>((ref) => GetMatchResultUseCase(ref.watch(matchRepositoryProvider)));
final getMatchDetailUseCaseProvider = Provider<GetMatchDetailUseCase>((ref) => GetMatchDetailUseCase(ref.watch(matchRepositoryProvider)));
final submitIntentionUseCaseProvider = Provider<SubmitIntentionUseCase>((ref) => SubmitIntentionUseCase(ref.watch(matchRepositoryProvider)));

final matchCountdownProvider = FutureProvider<MatchCountdownUiState>((ref) async {
  try {
    final data = await ref.read(getCountdownUseCaseProvider).call();
    return MatchCountdownUiState(data: data);
  } catch (e) {
    return MatchCountdownUiState(error: e.toString());
  }
});

final matchResultProvider = FutureProvider<MatchResultUiState>((ref) async {
  try {
    final data = await ref.read(getMatchResultUseCaseProvider).call();
    return MatchResultUiState(data: data);
  } catch (e) {
    return MatchResultUiState(error: e.toString());
  }
});

final matchDetailProvider = FutureProvider((ref) async {
  return ref.read(getMatchDetailUseCaseProvider).call();
});
