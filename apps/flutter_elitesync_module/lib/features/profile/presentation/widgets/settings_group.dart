import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: t.textPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
        SizedBox(height: t.spacing.xs),
        Container(
          decoration: BoxDecoration(
            color: t.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(t.radius.lg),
            border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
          ),
          child: Column(children: children),
        ),
        SizedBox(height: t.spacing.md),
      ],
    );
  }
}

class SettingsItemTile extends StatelessWidget {
  const SettingsItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: t.brandPrimary.withValues(alpha: 0.18),
        ),
        child: Icon(icon, size: 18, color: t.brandPrimary),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: t.textSecondary),
      ),
      trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: t.textTertiary),
      contentPadding: EdgeInsets.symmetric(horizontal: t.spacing.md, vertical: 2),
    );
  }
}
