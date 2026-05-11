import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/domain/entities/profile_summary_entity.dart';

class ProfileExpressionAdviceCard extends StatelessWidget {
  const ProfileExpressionAdviceCard({super.key, required this.summary});

  final ProfileSummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final model = _ProfileExpressionAdviceModel.fromSummary(summary);

    return AppInfoSectionCard(
      title: '我的慢约会表达建议',
      subtitle: '这些提示只帮助你整理表达方向，不会自动修改资料。',
      leadingIcon: Icons.psychology_alt_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            model.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: t.textPrimary,
              height: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          for (final dimension in model.dimensions) ...[
            _ExpressionDimensionRow(dimension: dimension),
            SizedBox(height: t.spacing.xs),
          ],
          SizedBox(height: t.spacing.sm),
          _ExpressionSuggestionSection(
            title: '资料展示建议',
            items: model.displaySuggestions,
          ),
          SizedBox(height: t.spacing.sm),
          _ExpressionSuggestionSection(
            title: '慢约会友好表达',
            items: model.slowDatingSuggestions,
          ),
          SizedBox(height: t.spacing.sm),
          _ExpressionSuggestionSection(
            title: '可以补充什么',
            items: model.completionSuggestions,
          ),
          SizedBox(height: t.spacing.sm),
          Wrap(
            spacing: t.spacing.sm,
            runSpacing: t.spacing.sm,
            children: const [
              AppChoiceChip(
                label: '帮我整理一句表达 · 敬请期待',
                leading: Icon(Icons.auto_awesome_outlined),
              ),
            ],
          ),
          SizedBox(height: t.spacing.sm),
          Text(
            '以上内容仅为自我表达参考，不会写入资料，不会改变星盘或匹配算法，也不会自动修改个人资料。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpressionDimensionRow extends StatelessWidget {
  const _ExpressionDimensionRow({required this.dimension});

  final _ExpressionDimensionData dimension;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 7),
          decoration: BoxDecoration(
            color: t.brandPrimary.withValues(alpha: 0.72),
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: t.spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: t.spacing.xs,
                runSpacing: t.spacing.xxs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    dimension.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: t.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _ExpressionTag(label: dimension.tag),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                dimension.body,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.42,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ExpressionTag extends StatelessWidget {
  const _ExpressionTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.xs,
        vertical: t.spacing.xxs,
      ),
      decoration: BoxDecoration(
        color: t.brandPrimary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(t.radius.pill),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: t.brandPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ExpressionSuggestionSection extends StatelessWidget {
  const _ExpressionSuggestionSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: t.spacing.xs),
        for (final item in items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.check_circle_outline, size: 16, color: t.brandPrimary),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
        ],
      ],
    );
  }
}

class _ProfileExpressionAdviceModel {
  const _ProfileExpressionAdviceModel({
    required this.summary,
    required this.dimensions,
    required this.displaySuggestions,
    required this.slowDatingSuggestions,
    required this.completionSuggestions,
  });

  final String summary;
  final List<_ExpressionDimensionData> dimensions;
  final List<String> displaySuggestions;
  final List<String> slowDatingSuggestions;
  final List<String> completionSuggestions;

  factory _ProfileExpressionAdviceModel.fromSummary(
    ProfileSummaryEntity summary,
  ) {
    final completion = (summary.completion * 100).round().clamp(0, 100);
    final hasCity = summary.city.trim().isNotEmpty;
    final hasTarget = summary.target.trim().isNotEmpty;
    final hasTags = summary.tags.isNotEmpty;
    final target = hasTarget ? _targetLabel(summary.target) : '慢慢了解';
    final summaryText = completion >= 70
        ? '你的资料已经能表达一部分真实状态，可以再补充一点互动偏好，让开场更自然。'
        : '当前资料还可以继续补充，先用轻松真实的方式介绍自己，会比堆满标签更适合慢约会。';

    return _ProfileExpressionAdviceModel(
      summary: summaryText,
      dimensions: [
        _ExpressionDimensionData(
          title: '真实感',
          tag: hasCity || hasTags ? '已有基础' : '可继续补充',
          body: hasCity
              ? '当前资料能让对方先看到你的生活位置和基本状态。'
              : '可以先补充一个不涉及隐私的生活状态，让资料更像真实的人。',
        ),
        _ExpressionDimensionData(
          title: '表达清晰度',
          tag: hasTags ? '可读' : '待补充',
          body: hasTags
              ? '已有标签可以作为开场线索，建议把标签转成具体相处方式。'
              : '当前标签较少，可以先写一句你通常怎样认识新朋友。',
        ),
        _ExpressionDimensionData(
          title: '慢约会适配度',
          tag: target,
          body: '适合把关系目标表达为愿意慢慢了解，而不是急着给彼此下结论。',
        ),
        const _ExpressionDimensionData(
          title: '开场友好度',
          tag: '低压',
          body: '用生活片段或共同兴趣开启对话，比直接推进关系更容易让人回应。',
        ),
      ],
      displaySuggestions: [
        '可以补一句你希望怎样慢慢认识别人。',
        hasTags ? '把现有标签写得更具体，方便别人找到自然开场点。' : '先补一个真实但轻松的兴趣或生活片段。',
      ],
      slowDatingSuggestions: [
        '用“可以先聊聊共同兴趣”代替强推进关系。',
        '让对方知道你愿意慢慢了解，而不是立刻给出承诺。',
      ],
      completionSuggestions: [
        '补充一个最近喜欢的事物。',
        '补充一个你舒服的聊天节奏。',
        '补充一个不涉及隐私的生活状态。',
      ],
    );
  }
}

class _ExpressionDimensionData {
  const _ExpressionDimensionData({
    required this.title,
    required this.tag,
    required this.body,
  });

  final String title;
  final String tag;
  final String body;
}

String _targetLabel(String raw) {
  switch (raw) {
    case 'marriage':
      return '结婚';
    case 'dating':
      return '恋爱';
    case 'friendship':
      return '交友';
    default:
      return raw;
  }
}
