import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync/features/home/presentation/providers/home_provider.dart';

@immutable
class ContentDetailQuery {
  const ContentDetailQuery({
    required this.contentId,
    this.seed,
  });

  final String contentId;
  final HomeFeedEntity? seed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContentDetailQuery && runtimeType == other.runtimeType && contentId == other.contentId;

  @override
  int get hashCode => contentId.hashCode;
}

final contentDetailProvider = FutureProvider.family<HomeFeedEntity, ContentDetailQuery>((
  ref,
  query,
) async {
  final remote = ref.read(homeRemoteDataSourceProvider);
  final mapper = const HomeMapper();
  try {
    final dto = await remote.fetchContentDetail(query.contentId);
    return mapper.feed(dto);
  } catch (_) {
    if (query.seed != null) return query.seed!;
    return HomeFeedEntity(
      id: query.contentId,
      title: '内容详情',
      summary: '内容正在准备中，请稍后查看。',
      author: '系统',
      likes: 0,
      body: '当前内容详情接口尚未返回正文，已使用本地占位内容。',
      tags: const ['建设中'],
    );
  }
});
