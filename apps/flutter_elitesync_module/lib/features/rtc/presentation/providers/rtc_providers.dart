import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_elitesync_module/features/rtc/data/datasource/rtc_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/entities/rtc_session_entity.dart';
import 'package:flutter_elitesync_module/features/rtc/domain/services/rtc_livekit_service.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final rtcRemoteDataSourceProvider = Provider<RtcRemoteDataSource>((ref) {
  return RtcRemoteDataSource(apiClient: ref.watch(apiClientProvider));
});

final rtcCallsProvider = FutureProvider<List<RtcSessionEntity>>((ref) async {
  return ref.read(rtcRemoteDataSourceProvider).fetchCalls();
});

final rtcCallProvider = FutureProvider.family<RtcSessionEntity, int>((
  ref,
  callId,
) async {
  return ref.read(rtcRemoteDataSourceProvider).fetchCall(callId);
});

final rtcLiveKitServiceProvider = ChangeNotifierProvider<RtcLiveKitService>((ref) {
  return RtcLiveKitService(
    remoteDataSource: ref.watch(rtcRemoteDataSourceProvider),
    appEnv: ref.watch(appEnvProvider),
  );
});
