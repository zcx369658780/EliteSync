import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final performanceLiteModeProvider = FutureProvider<bool>((ref) async {
  final v = await ref.read(localStorageProvider).getBool(CacheKeys.performanceLiteMode);
  return v ?? false;
});

