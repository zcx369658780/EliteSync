import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [t.brandPrimary, t.brandSecondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(t.radius.lg),
          ),
          child: const Icon(
            Icons.auto_awesome_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        SizedBox(height: t.spacing.lg),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: t.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: t.spacing.xs),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: t.textSecondary),
        ),
      ],
    );
  }
}
