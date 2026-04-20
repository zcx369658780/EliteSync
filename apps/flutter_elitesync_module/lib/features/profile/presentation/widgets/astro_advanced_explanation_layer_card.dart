import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/astro_advanced_profile_provider.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/widgets/astro_profile_sections.dart';

class AstroAdvancedExplanationLayerCard extends StatelessWidget {
  const AstroAdvancedExplanationLayerCard({super.key, required this.bundle});

  final AstroAdvancedPreviewBundle bundle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final entries = bundle.items
        .expand((item) => item.buildExplainabilityEntries())
        .toList(growable: false);

    return AppInfoSectionCard(
      title: '细粒度解释层',
      subtitle: '摘要层 / 条目层 / 高级时法关联层',
      leadingIcon: Icons.notes_rounded,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3.9 这一层不再只给整段摘要，而是把相位、点位和关联关系拆成可浏览的条目。所有内容仍停留在 display-only / advanced-context，不回写 canonical truth。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            '每张卡片都按“证据 -> 解释 -> 提示”组织，方便单独截图、快速复核和归档。',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '摘要层',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: bundle.items
                  .map(
                    (item) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.xs),
                      child: _SummaryTile(item: item),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '条目层',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: entries
                  .map(
                    (entry) => Padding(
                      padding: EdgeInsets.only(bottom: t.spacing.xs),
                      child: _ExplainabilityEntryTile(entry: entry),
                    ),
                  )
                  .toList(growable: false),
            ),
          ),
          SizedBox(height: t.spacing.sm),
          _LayerSection(
            title: '高级时法关联层',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TimingAssociationTile(
                  title: bundle.timing.formalSignal.title,
                  summary: bundle.timing.formalSignal.summary,
                  accent: const Color(0xFF4BCB92),
                  badges: bundle.timing.formalSignal.badges,
                ),
                SizedBox(height: t.spacing.xs),
                _TimingAssociationTile(
                  title: bundle.timing.placeholderSignal.title,
                  summary: bundle.timing.placeholderSignal.summary,
                  accent: const Color(0xFFF5A623),
                  badges: bundle.timing.placeholderSignal.badges,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LayerSection extends StatelessWidget {
  const _LayerSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: t.spacing.xs),
        child,
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({required this.item});

  final AstroAdvancedPreviewItem item;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF5AA8FF).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(
          color: const Color(0xFF5AA8FF).withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5AA8FF),
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            item.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Wrap(
            spacing: t.spacing.xs,
            runSpacing: t.spacing.xs,
            children: [
              AstroPill(label: item.routeLabel, color: const Color(0xFF5AA8FF)),
              AstroPill(label: item.modeLabel, color: const Color(0xFF5AA8FF)),
              AstroPill(
                label: item.metricsLabel,
                color: const Color(0xFF5AA8FF),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExplainabilityEntryTile extends StatelessWidget {
  const _ExplainabilityEntryTile({required this.entry});

  final AstroExplainabilityEntry entry;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final accent = switch (entry.layerLabel) {
      '相位级' => const Color(0xFF5AA8FF),
      '点位级' => const Color(0xFF8F7BFF),
      _ => const Color(0xFF4BCB92),
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  entry.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
              ),
              Text(
                entry.layerLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: accent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            entry.summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          SizedBox(height: t.spacing.xs),
          Text(
            entry.detail,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          if (entry.badges.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: entry.badges
                  .map((badge) => AstroPill(label: badge, color: accent))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimingAssociationTile extends StatelessWidget {
  const _TimingAssociationTile({
    required this.title,
    required this.summary,
    required this.accent,
    required this.badges,
  });

  final String title;
  final String summary;
  final Color accent;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(t.spacing.md),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(t.radius.lg),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
          SizedBox(height: t.spacing.xxs),
          Text(
            summary,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              height: 1.45,
            ),
          ),
          if (badges.isNotEmpty) ...[
            SizedBox(height: t.spacing.xs),
            Wrap(
              spacing: t.spacing.xs,
              runSpacing: t.spacing.xs,
              children: badges
                  .map((badge) => AstroPill(label: badge, color: accent))
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}
