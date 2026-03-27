import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_top_bar.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync/design_system/components/layout/app_scaffold.dart';
import 'package:flutter_elitesync/design_system/components/layout/page_title_rail.dart';
import 'package:flutter_elitesync/design_system/components/layout/section_reveal.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class MbtiCenterPage extends StatelessWidget {
  const MbtiCenterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: 'MBTI测试', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: 'MBTI 快速测评',
              subtitle: '3题简版，用于匹配解释与画像补充',
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 70),
            child: Container(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              decoration: BoxDecoration(
                color: t.browseSurface,
                borderRadius: BorderRadius.circular(t.radius.lg),
                border: Border.all(color: t.browseBorder),
              ),
              child: Text(
                '当前 MBTI 题目已并入性格问卷流程。后续会拆分为独立题库并支持多版本。你可以现在开始测试，结果将自动用于匹配。',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: t.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ),
          SizedBox(height: t.spacing.md),
          SectionReveal(
            delay: const Duration(milliseconds: 140),
            child: AppPrimaryButton(
              label: '开始 MBTI 测试',
              onPressed: () => context.push(AppRouteNames.questionnaire),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '查看匹配解释',
              fullWidth: true,
              onPressed: () => context.push(AppRouteNames.matchDetail),
            ),
          ),
        ],
      ),
    );
  }
}
