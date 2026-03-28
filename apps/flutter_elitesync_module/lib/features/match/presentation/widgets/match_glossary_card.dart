import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class MatchGlossaryCard extends StatelessWidget {
  const MatchGlossaryCard({
    super.key,
    required this.entries,
  });

  final List<MapEntry<String, String>> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final t = context.appTokens;
    return Container(
      margin: EdgeInsets.only(bottom: t.spacing.sm),
      decoration: BoxDecoration(
        color: t.browseSurface,
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: t.browseBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              t.spacing.cardPadding,
              t.spacing.cardPadding,
              t.spacing.cardPadding,
              t.spacing.xs,
            ),
            child: Text(
              '术语解释',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: t.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          ...entries.map(
            (e) => Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: EdgeInsets.symmetric(horizontal: t.spacing.cardPadding),
                childrenPadding: EdgeInsets.fromLTRB(
                  t.spacing.cardPadding,
                  0,
                  t.spacing.cardPadding,
                  t.spacing.sm,
                ),
                iconColor: t.textSecondary,
                collapsedIconColor: t.textSecondary,
                title: Text(
                  e.key,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      e.value,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: t.textSecondary,
                            height: 1.45,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

