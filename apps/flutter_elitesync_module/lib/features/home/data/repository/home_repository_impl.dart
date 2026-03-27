import 'package:flutter_elitesync_module/features/home/data/datasource/home_remote_data_source.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_shortcut_entity.dart';
import 'package:flutter_elitesync_module/features/home/domain/repository/home_repository.dart';

class HomeRepositoryImpl implements HomeRepository {
  const HomeRepositoryImpl({required this.remote, required this.mapper});

  final HomeRemoteDataSource remote;
  final HomeMapper mapper;

  @override
  Future<HomeBannerEntity> getBanner() async => mapper.banner(await remote.fetchBanner());

  @override
  Future<List<HomeFeedEntity>> getFeed() async => (await remote.fetchFeed()).map(mapper.feed).toList();

  @override
  Future<List<HomeShortcutEntity>> getShortcuts() async => (await remote.fetchShortcuts()).map(mapper.shortcut).toList();
}
