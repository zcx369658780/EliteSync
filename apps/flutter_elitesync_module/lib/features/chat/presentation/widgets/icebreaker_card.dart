import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class IcebreakerSuggestion {
  const IcebreakerSuggestion({
    required this.label,
    required this.prompt,
    this.lane = '首聊',
    this.source = '关系摘要',
    this.description = '',
    this.icon = Icons.auto_awesome_rounded,
  });

  final String label;
  final String prompt;
  final String lane;
  final String source;
  final String description;
  final IconData icon;
}

class IcebreakerCard extends StatelessWidget {
  const IcebreakerCard({
    super.key,
    this.suggestions = const [],
    this.onSuggestionTap,
  });

  final List<IcebreakerSuggestion> suggestions;
  final ValueChanged<String>? onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '首聊 / 恢复建议',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '点一下就能把话题草稿放进输入框，适合开场、接话或回到上一个话题。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: t.textSecondary,
                height: 1.35,
              ),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 10),
              Column(
                children: suggestions
                    .map(
                      (item) => _SuggestionRow(
                        item: item,
                        onTap: onSuggestionTap == null
                            ? null
                            : () => onSuggestionTap!(item.prompt),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.item, this.onTap});

  final IcebreakerSuggestion item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(t.radius.md),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(t.spacing.sm),
          decoration: BoxDecoration(
            color: t.secondarySurface.withValues(alpha: 0.62),
            borderRadius: BorderRadius.circular(t.radius.md),
            border: Border.all(color: t.overlay.withValues(alpha: 0.55)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(item.icon, size: 16, color: t.brandPrimary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  AppChoiceChip(label: item.lane, selected: true),
                ],
              ),
              if (item.description.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: t.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                item.prompt,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: t.textPrimary,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '来源：${item.source}。点击只写入草稿，不会自动发送。',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: t.textSecondary,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
