import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';

final discoverProvider = FutureProvider.family<List<HomeFeedEntity>, String>((ref, tab) async {
  final remote = ref.read(homeRemoteDataSourceProvider);
  final mapper = const HomeMapper();
  final page = await remote.fetchDiscoverFeedPage(tab: tab, limit: 12);
  return page.items.map(mapper.feed).toList();
});
