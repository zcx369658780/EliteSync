import 'package:flutter_elitesync_module/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';

abstract class HomeRepository {
  Future<HomeBannerEntity> getBanner();
  Future<List<HomeShortcutEntity>> getShortcuts();
  Future<List<HomeFeedEntity>> getFeed();
}
