import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/components/states/app_error_state.dart';
import 'package:flutter_elitesync/design_system/components/states/app_loading_skeleton.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/features/verification/presentation/providers/verification_provider.dart';
import 'package:flutter_elitesync/features/verification/presentation/widgets/verification_requirement_card.dart';
import 'package:flutter_elitesync/features/verification/presentation/widgets/verification_status_card.dart';

class VerificationStatusPage extends ConsumerWidget {
  const VerificationStatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(verificationProvider);

    return AppScaffold(
      appBar: const AppTopBar(title: '实名认证', mode: AppTopBarMode.backTitle),
      body: asyncState.when(
        loading: () => const AppLoadingSkeleton(lines: 6),
        error: (e, _) => AppErrorState(
          title: '认证状态加载失败',
          description: e.toString(),
          onRetry: () => ref.read(verificationProvider.notifier).refresh(),
        ),
        data: (state) {
          final status = state.status;
          if (status == null) {
            return const AppErrorState(title: '认证状态为空', description: '请稍后重试');
          }

          final t = context.appTokens;
          return ListView(
            children: [
              SizedBox(height: t.spacing.md),
              const SectionReveal(
                child: PageTitleRail(
                  title: '实名认证',
                  subtitle: '完成后可提升资料可信度与匹配质量',
                ),
              ),
              SizedBox(height: t.spacing.md),
              SectionReveal(
                delay: const Duration(milliseconds: 70),
                child: VerificationStatusCard(
                  status: status.status,
                  title: status.title,
                  description: status.description,
                ),
              ),
              SizedBox(height: t.spacing.md),
              const SectionReveal(
                delay: Duration(milliseconds: 120),
                child: VerificationRequirementCard(),
              ),
              SizedBox(height: t.spacing.md),
              SectionReveal(
                delay: const Duration(milliseconds: 170),
                child: AppPrimaryButton(
                  label: '去提交认证',
                  onPressed: () => context.push(AppRouteNames.verificationSubmit),
                ),
              ),
              if ((state.message ?? '').isNotEmpty) ...[
                SizedBox(height: t.spacing.sm),
                Text(state.message!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.success)),
              ],
              if ((state.error ?? '').isNotEmpty) ...[
                SizedBox(height: t.spacing.sm),
                Text(state.error!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.error)),
              ],
            ],
          );
        },
      ),
    );
  }
}
