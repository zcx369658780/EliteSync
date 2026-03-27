import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class CategoryTabStrip extends StatelessWidget {
  const CategoryTabStrip({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (context, index) => SizedBox(width: t.spacing.xs),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return Material(
            color: selected ? t.brandPrimary.withValues(alpha: 0.14) : t.browseChip,
            borderRadius: BorderRadius.circular(t.radius.pill),
            child: InkWell(
              borderRadius: BorderRadius.circular(t.radius.pill),
              onTap: () => onSelected(index),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: t.spacing.md,
                  vertical: t.spacing.xs,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(t.radius.pill),
                  border: Border.all(
                    color: selected ? t.brandPrimary : t.browseBorder,
                  ),
                ),
                child: Text(
                  tabs[index],
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: selected ? t.brandPrimary : t.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
