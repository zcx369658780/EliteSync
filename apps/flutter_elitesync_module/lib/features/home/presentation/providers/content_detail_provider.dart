import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/features/home/data/mapper/home_mapper.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';

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
  HomeFeedEntity ensureRichContent(HomeFeedEntity input) {
    final body = (input.body ?? '').trim();
    final tags = input.tags.isNotEmpty
        ? input.tags
        : const ['慢约会观察', '关系沟通', '相处节奏'];
    if (body.isNotEmpty) {
      return HomeFeedEntity(
        id: input.id,
        title: input.title,
        summary: input.summary,
        author: input.author,
        likes: input.likes,
        body: body,
        media: input.media,
        tags: tags,
      );
    }
    final generated = [
      '导语：${input.summary}',
      '在慢约会场景里，关系进展通常不是“谁更主动”决定的，而是双方是否能在节奏、反馈和预期上建立稳定共识。',
      '可执行建议：先约定沟通频率，再约定分歧处理方式。这样做能明显减少误读，也更容易建立安全感。',
      '结论：当互动质量稳定高于互动频率时，关系更容易长期维持。'
    ].join('\n\n');
    return HomeFeedEntity(
      id: input.id,
      title: input.title,
      summary: input.summary,
      author: input.author,
      likes: input.likes,
      body: generated,
      media: input.media,
      tags: tags,
    );
  }

  try {
    final dto = await remote.fetchContentDetail(query.contentId);
    return ensureRichContent(mapper.feed(dto));
  } catch (_) {
    if (query.seed != null) return ensureRichContent(query.seed!);
    return ensureRichContent(HomeFeedEntity(
      id: query.contentId,
      title: '内容详情',
      summary: '内容正在准备中，请稍后查看。',
      author: '系统',
      likes: 0,
      body: '',
      tags: const ['建设中'],
    ));
  }
});
