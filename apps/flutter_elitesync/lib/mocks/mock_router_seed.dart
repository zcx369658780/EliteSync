import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

class MockRouterSeed {
  const MockRouterSeed({required this.startRoute, required this.forceAuth});

  final String startRoute;
  final bool forceAuth;
}

final mockEnabledProvider = Provider<bool>((ref) {
  return ref.watch(appEnvProvider).useMockData;
});

final mockRouterSeedProvider = Provider<MockRouterSeed>((ref) {
  // T09 仅提供固定种子；后续可按用户状态动态生成。
  return const MockRouterSeed(startRoute: '/home', forceAuth: true);
});
