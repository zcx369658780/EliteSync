import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/states/app_empty_state.dart';

import 'astro_profile_state.dart';

class AstroProfileStateView extends StatelessWidget {
  const AstroProfileStateView({
    super.key,
    required this.spec,
    this.onAction,
  });

  final AstroProfileStateSpec spec;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      title: spec.title,
      description: spec.description,
      icon: spec.icon,
      actionLabel: spec.actionLabel,
      onAction: onAction,
    );
  }
}