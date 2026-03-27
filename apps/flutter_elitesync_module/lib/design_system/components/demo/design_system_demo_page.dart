import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_ghost_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_hero_card.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_tag.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class DesignSystemDemoPage extends StatelessWidget {
  const DesignSystemDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;

    return Scaffold(
      appBar: AppBar(title: const Text('Design System Demo')),
      body: ListView(
        padding: EdgeInsets.all(t.spacing.pageHorizontal),
        children: [
          AppHeroCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'EliteSync UI 组件预览',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.spacing.xs),
                Text(
                  'T04: Buttons / Cards / Tags',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.section),
          const AppPrimaryButton(label: 'Primary 按钮'),
          SizedBox(height: t.spacing.md),
          Row(
            children: [
              Expanded(
                child: AppSecondaryButton(label: 'Secondary', onPressed: () {}),
              ),
              SizedBox(width: t.spacing.md),
              Expanded(
                child: AppSecondaryButton(
                  label: 'Outline',
                  style: AppSecondaryButtonStyle.outline,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          Align(
            alignment: Alignment.centerLeft,
            child: AppGhostButton(label: 'Ghost 按钮', onPressed: () {}),
          ),
          SizedBox(height: t.spacing.section),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('通用卡片', style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: t.spacing.xs),
                Text(
                  '用于承载普通内容模块。',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          SizedBox(height: t.spacing.md),
          const AppInfoCard(
            title: '信息提示卡片',
            description: '用于展示说明、状态、提示和引导。',
            icon: Icon(Icons.info_outline),
          ),
          SizedBox(height: t.spacing.section),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: const [
              AppTag(label: '品牌', variant: AppTagVariant.brand),
              AppTag(label: '成功', variant: AppTagVariant.success),
              AppTag(label: '警告', variant: AppTagVariant.warning),
              AppTag(label: '危险', variant: AppTagVariant.danger),
              AppTag(label: '中性', variant: AppTagVariant.neutral),
              AppTag(label: '描边', variant: AppTagVariant.outlined),
            ],
          ),
        ],
      ),
    );
  }
}
