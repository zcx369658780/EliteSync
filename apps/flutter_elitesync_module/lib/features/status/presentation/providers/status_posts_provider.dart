import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/status/data/datasource/status_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/status/domain/entities/status_post_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final statusRemoteDataSourceProvider = Provider<StatusRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return StatusRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockData,
  );
});

final statusPostsProvider = FutureProvider<List<StatusPostEntity>>((ref) async {
  return ref.read(statusRemoteDataSourceProvider).fetchStatusPosts(limit: 20);
});
