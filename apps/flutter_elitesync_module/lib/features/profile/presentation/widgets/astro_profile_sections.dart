import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_info_section_card.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

Map<String, dynamic> astroMap(dynamic value) =>
    value is Map<String, dynamic> ? value : const <String, dynamic>{};

List<dynamic> astroList(dynamic value) =>
    value is List<dynamic> ? value : const <dynamic>[];

String astroText(dynamic value, [String fallback = '未填写']) {
  final text = (value ?? '').toString().trim();
  return text.isEmpty ? fallback : text;
}

double? astroDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse((value ?? '').toString());
}

String astroDateTimeLabel(dynamic value) {
  final raw = (value ?? '').toString().trim();
  if (raw.isEmpty) return '未更新';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return raw;
  final local = parsed.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}

class AstroSectionCard extends StatelessWidget {
  const AstroSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.child,
    this.fullWidth = false,
    this.isFullWidth,
    this.edgeToEdge = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final bool fullWidth;
  final bool? isFullWidth;
  final bool edgeToEdge;

  @override
  Widget build(BuildContext context) {
    if (edgeToEdge) {
      final t = context.appTokens;
      return Container(
        decoration: BoxDecoration(
          color: t.browseSurface,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: Colors.transparent, width: 0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                top: t.spacing.cardPaddingLarge,
                bottom: t.spacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (icon != null) ...[
                        Icon(icon, size: 18, color: t.brandPrimary),
                        SizedBox(width: t.spacing.xs),
                      ],
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  if ((subtitle ?? '').trim().isNotEmpty) ...[
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      subtitle!.trim(),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: t.textSecondary),
                    ),
                  ],
                  SizedBox(height: t.spacing.sm),
                ],
              ),
            ),
            child,
          ],
        ),
      );
    }
    return AppInfoSectionCard(
      title: title,
      subtitle: subtitle,
      leadingIcon: icon,
      fullWidth: fullWidth,
      isFullWidth: isFullWidth,
      child: child,
    );
  }
}

class AstroKeyValueRow extends StatelessWidget {
  const AstroKeyValueRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 96,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: t.textPrimary,
              fontWeight: emphasis ? FontWeight.w700 : FontWeight.w400,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class AstroPill extends StatelessWidget {
  const AstroPill({super.key, required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final fg = color ?? t.brandPrimary;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: t.spacing.sm,
        vertical: t.spacing.xs,
      ),
      decoration: BoxDecoration(
        color: fg.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radius.pill),
        border: Border.all(color: fg.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class AstroModuleCard extends StatelessWidget {
  const AstroModuleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.onTap,
    this.badge,
    this.icon,
  });

  final String title;
  final String subtitle;
  final String summary;
  final VoidCallback onTap;
  final String? badge;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(t.radius.lg),
        child: Container(
          padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
          decoration: BoxDecoration(
            color: t.browseSurface,
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.browseBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: t.brandPrimary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(t.radius.md),
                ),
                child: Icon(
                  icon ?? Icons.auto_awesome_outlined,
                  color: t.brandPrimary,
                  size: 20,
                ),
              ),
              SizedBox(width: t.spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  color: t.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        if ((badge ?? '').isNotEmpty) AstroPill(label: badge!),
                      ],
                    ),
                    SizedBox(height: t.spacing.xxs),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textSecondary,
                        height: 1.35,
                      ),
                    ),
                    SizedBox(height: t.spacing.xs),
                    Text(
                      summary,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: t.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
