import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/features/notification/data/datasource/notification_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/notification/domain/entities/notification_item_entity.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final notificationRemoteDataSourceProvider =
    Provider<NotificationRemoteDataSource>((ref) {
  final env = ref.watch(appEnvProvider);
  return NotificationRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
    useMock: env.useMockData,
  );
});

final notificationListProvider =
    FutureProvider<List<NotificationItemEntity>>((ref) async {
  return ref.read(notificationRemoteDataSourceProvider).fetchNotifications();
});

final notificationUnreadCountProvider = FutureProvider<int>((ref) async {
  return ref.read(notificationRemoteDataSourceProvider).fetchUnreadCount();
});

final notificationPreferencesProvider = FutureProvider<bool>((ref) async {
  final local = ref.read(localStorageProvider);
  return await local.getBool(CacheKeys.pushNotificationEnabled) ?? true;
});
