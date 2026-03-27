import 'package:flutter_elitesync/features/home/data/dto/home_banner_dto.dart';
import 'package:flutter_elitesync/features/home/data/dto/home_feed_dto.dart';
import 'package:flutter_elitesync/features/home/data/dto/shortcut_entry_dto.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_banner_entity.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_shortcut_entity.dart';

class HomeMapper {
  const HomeMapper();

  HomeBannerEntity banner(HomeBannerDto dto) => HomeBannerEntity(title: dto.title, subtitle: dto.subtitle, cta: dto.cta);

  HomeShortcutEntity shortcut(ShortcutEntryDto dto) => HomeShortcutEntity(
        key: dto.key,
        title: dto.title,
        action: dto.action,
        target: dto.target,
      );

  HomeFeedEntity feed(HomeFeedDto dto) => HomeFeedEntity(
        id: dto.id,
        title: dto.title,
        summary: dto.summary,
        author: dto.author,
        likes: dto.likes,
        body: dto.body,
        media: dto.media,
        tags: dto.tags,
      );
}
