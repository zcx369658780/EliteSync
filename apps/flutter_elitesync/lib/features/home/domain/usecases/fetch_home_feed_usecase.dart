import 'package:flutter_elitesync/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync/features/home/domain/repository/home_repository.dart';

class HomeBundle {
  const HomeBundle({required this.banner, required this.shortcuts, required this.feed});

  final HomeBannerEntity banner;
  final List<HomeShortcutEntity> shortcuts;
  final List<HomeFeedEntity> feed;
}

class FetchHomeFeedUseCase {
  const FetchHomeFeedUseCase(this.repository);

  final HomeRepository repository;

  Future<HomeBundle> call() async {
    final banner = await repository.getBanner();
    final shortcuts = await repository.getShortcuts();
    final feed = await repository.getFeed();
    return HomeBundle(banner: banner, shortcuts: shortcuts, feed: feed);
  }
}
