import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync/design_system/components/layout/browse_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/match/domain/entities/match_detail_entity.dart';
import 'package:flutter_elitesync/features/match/domain/entities/match_result_entity.dart';
import 'package:flutter_elitesync/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_hero_summary_card.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_reason_card.dart';

class MatchUnlockPage extends ConsumerStatefulWidget {
  const MatchUnlockPage({super.key});

  @override
  ConsumerState<MatchUnlockPage> createState() => _MatchUnlockPageState();
}

class _MatchUnlockPageState extends ConsumerState<MatchUnlockPage> {
  int _seed = 0;

  List<String> _icebreakers(
    MatchResultEntity result,
    MatchDetailEntity detail,
  ) {
    final tags = result.tags.where((e) => e.trim().isNotEmpty).take(3).toList();
    final reasonHints = detail.reasons.take(2).toList();
    final firstTag = tags.isNotEmpty ? tags.first : '最近的生活节奏';
    final secondTag = tags.length > 1 ? tags[1] : '周末安排';
    final reason = reasonHints.isNotEmpty ? reasonHints.first : '沟通节奏';
    final list = [
      '如果先从$firstTag聊起，你会想先问对方什么？',
      '你更喜欢先聊$secondTag，还是直接约一次轻松见面？',
      '这次匹配里最让你想继续了解的一点是什么？',
      '如果围绕$reason展开，你会想继续聊哪一块？',
    ];
    list.shuffle(Random(_seed + result.score + detail.reasons.length));
    return list.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final resultAsync = ref.watch(matchResultProvider);
    final detailAsync = ref.watch(matchDetailProvider);
    final t = context.appTokens;

    return BrowseScaffold(
      header: SizedBox(
        height: 44,
        child: Row(
          children: [
            Text(
              '解锁资料',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                setState(() => _seed++);
                ref.invalidate(matchResultProvider);
                ref.invalidate(matchDetailProvider);
              },
              icon: Icon(Icons.refresh_rounded, color: t.textSecondary),
            ),
          ],
        ),
      ),
      body: resultAsync.when(
        loading: () => const AppLoadingSkeleton(lines: 7),
        error: (e, _) =>
            AppErrorState(title: '解锁页加载失败', description: e.toString()),
        data: (state) {
          final result = state.data;
          if (result == null) {
            return const AppErrorState(
              title: '暂无解锁内容',
              description: '请先完成揭晓与双边确认',
            );
          }
          return detailAsync.when(
            loading: () => const AppLoadingSkeleton(lines: 5),
            error: (e, _) =>
                AppErrorState(title: '解释加载失败', description: e.toString()),
            data: (detail) {
              final icebreakers = _icebreakers(result, detail);
              return ListView(
                padding: EdgeInsets.only(
                  top: t.spacing.xs,
                  bottom: t.spacing.huge,
                ),
                children: [
                  const SectionReveal(
                    child: PageTitleRail(
                      title: '双边喜欢解锁态',
                      subtitle: '先看完整轮廓，再看破冰问题，最后决定怎么开聊',
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                  SectionReveal(
                    delay: const Duration(milliseconds: 40),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lock_open_rounded,
                                color: t.success,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '资料已解锁',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: t.textPrimary,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                          SizedBox(height: t.spacing.sm),
                          Text(
                            '双方都愿意继续了解后，资料会从悬念版切换到完整版。',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: t.textSecondary,
                                  height: 1.45,
                                ),
                          ),
                          SizedBox(height: t.spacing.md),
                          MatchHeroSummaryCard(
                            headline: result.headline,
                            score: result.score,
                            tags: result.tags,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                  SectionReveal(
                    delay: const Duration(milliseconds: 80),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '完整解释',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          ...detail.reasons
                              .take(3)
                              .map(
                                (reason) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: MatchReasonCard(reason: reason),
                                ),
                              ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: t.spacing.md),
                  SectionReveal(
                    delay: const Duration(milliseconds: 120),
                    child: AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '破冰问题',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          SizedBox(height: t.spacing.sm),
                          ...icebreakers.asMap().entries.map(
                            (entry) => Padding(
                              padding: EdgeInsets.only(bottom: t.spacing.sm),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    entry.value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: t.textPrimary,
                                          height: 1.45,
                                        ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text('已复制到聊天输入区（示意）'),
                                            ),
                                          );
                                        },
                                        child: const Text('发送这句话'),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '问题 ${entry.key + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: t.textSecondary.withValues(
                                                alpha: 0.78,
                                              ),
                                            ),
                                      ),
                                    ],
                                  ),
                                  if (entry.key != icebreakers.length - 1)
                                    const Divider(height: 18),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: t.spacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: AppSecondaryButton(
                                  label: '换一组',
                                  fullWidth: true,
                                  onPressed: () => setState(() => _seed++),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppPrimaryButton(
                                  label: '去聊天',
                                  onPressed: () =>
                                      context.go(AppRouteNames.messages),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
