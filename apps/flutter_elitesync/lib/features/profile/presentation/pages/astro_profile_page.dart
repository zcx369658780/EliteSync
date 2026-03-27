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

class AstroProfilePage extends StatelessWidget {
  const AstroProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppScaffold(
      appBar: const AppTopBar(title: '星盘画像', mode: AppTopBarMode.backTitle),
      body: ListView(
        padding: EdgeInsets.only(top: t.spacing.sm, bottom: t.spacing.xl),
        children: [
          const SectionReveal(
            child: PageTitleRail(
              title: '星座 / 星盘 / 八字画像',
              subtitle: '用于匹配结果中的过程与结论解释',
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
                '当前画像结果已接入匹配解释链路。下一阶段会把图谱与分项证据可视化，支持按维度查看：属相、八字、星座、星盘。',
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
              label: '查看匹配画像解释',
              onPressed: () => context.push(AppRouteNames.matchDetail),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          SectionReveal(
            delay: const Duration(milliseconds: 180),
            child: AppSecondaryButton(
              label: '返回匹配首页',
              fullWidth: true,
              onPressed: () => context.go(AppRouteNames.match),
            ),
          ),
        ],
      ),
    );
  }
}
