import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_intention_action_bar.dart';

class MatchIntentionPage extends ConsumerWidget {
  const MatchIntentionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '关系意向', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '关系意向',
              subtitle: '你愿意和这个人进一步认识吗？',
            ),
          ),
          const SizedBox(height: 16),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: MatchIntentionActionBar(
              onAccept: () async {
                await ref.read(submitIntentionUseCaseProvider).call('accept');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已发送愿意认识')));
                }
              },
              onLater: () async {
                await ref.read(submitIntentionUseCaseProvider).call('later');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('已设置稍后决定')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
