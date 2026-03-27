import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync_module/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/match/presentation/widgets/match_intention_action_bar.dart';

class MatchIntentionPage extends ConsumerStatefulWidget {
  const MatchIntentionPage({super.key});

  @override
  ConsumerState<MatchIntentionPage> createState() => _MatchIntentionPageState();
}

class _MatchIntentionPageState extends ConsumerState<MatchIntentionPage> {
  bool _submitting = false;

  Future<void> _submit(String action) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      await ref.read(submitIntentionUseCaseProvider).call(action);
      if (!mounted) return;
      final msg = action == 'accept' ? '已发送愿意认识' : '已设置稍后决定';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('提交失败：$e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              submitting: _submitting,
              onAccept: () => _submit('accept'),
              onLater: () => _submit('later'),
            ),
          ),
        ],
      ),
    );
  }
}
