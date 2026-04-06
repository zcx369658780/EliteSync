import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/moderation/data/datasource/moderation_remote_data_source.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final moderationRemoteDataSourceProvider = Provider<ModerationRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return ModerationRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockData,
  );
});
