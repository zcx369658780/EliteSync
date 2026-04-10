import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/tags/app_choice_chip.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class IcebreakerSuggestion {
  const IcebreakerSuggestion({required this.label, required this.prompt});

  final String label;
  final String prompt;
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
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: suggestions
                    .map(
                      (item) => AppChoiceChip(
                        label: item.label,
                        leading: const Icon(Icons.auto_awesome_rounded),
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
