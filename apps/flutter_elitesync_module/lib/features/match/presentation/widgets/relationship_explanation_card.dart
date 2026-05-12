import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/buttons/app_secondary_button.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class RelationshipExplanationDimension {
  const RelationshipExplanationDimension({
    required this.title,
    required this.description,
    this.tag,
  });

  final String title;
  final String description;
  final String? tag;
}

class RelationshipExplanationCard extends StatelessWidget {
  const RelationshipExplanationCard({
    super.key,
    required this.summary,
    required this.dimensions,
    required this.suggestions,
    required this.avoidances,
  });

  final String summary;
  final List<RelationshipExplanationDimension> dimensions;
  final List<String> suggestions;
  final List<String> avoidances;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AppCard(
      padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
      border: Border.all(color: t.brandPrimary.withValues(alpha: 0.16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.forum_outlined, size: 20, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '为什么值得聊',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      '这些提示只帮助你理解开场方向，不会改变匹配结果。',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          ...dimensions.map(
            (item) => Padding(
              padding: EdgeInsets.only(bottom: t.spacing.xs),
              child: _RelationshipDimensionRow(item: item),
            ),
          ),
          SizedBox(height: t.spacing.xs),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 420;
              final children = [
                _RelationshipAdviceBlock(
                  title: '建议这样开始',
                  icon: Icons.lightbulb_outline_rounded,
                  items: suggestions,
                ),
                _RelationshipAdviceBlock(
                  title: '先避免这样表达',
                  icon: Icons.do_not_disturb_on_outlined,
                  items: avoidances,
                ),
              ];
              if (narrow) {
                return Column(
                  children: [
                    children[0],
                    SizedBox(height: t.spacing.xs),
                    children[1],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: children[0]),
                  SizedBox(width: t.spacing.sm),
                  Expanded(child: children[1]),
                ],
              );
            },
          ),
          SizedBox(height: t.spacing.sm),
          AppSecondaryButton(
            label: '轻追问建议 · 敬请期待',
            onPressed: null,
            fullWidth: true,
            prefixIcon: const Icon(Icons.auto_awesome_rounded, size: 18),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '以上内容仅为关系理解与开场参考，不会写入资料，不会改变匹配算法，也不会自动发送消息。',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: t.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _RelationshipDimensionRow extends StatelessWidget {
  const _RelationshipDimensionRow({required this.item});

  final RelationshipExplanationDimension item;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseChip.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(t.radius.md),
        border: Border.all(color: t.browseBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: t.spacing.xxs),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if ((item.tag ?? '').trim().isNotEmpty) ...[
            SizedBox(width: t.spacing.xs),
            AppChoiceChip(label: item.tag!.trim(), selected: true),
          ],
        ],
      ),
    );
  }
}

class _RelationshipAdviceBlock extends StatelessWidget {
  const _RelationshipAdviceBlock({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.sm),
      decoration: BoxDecoration(
        color: t.secondarySurface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(t.radius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: t.brandPrimary),
              SizedBox(width: t.spacing.xxs),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xs),
          ...items
              .take(2)
              .map(
                (item) => Padding(
                  padding: EdgeInsets.only(bottom: t.spacing.xxs),
                  child: Text(
                    item,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: t.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
