import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class SectionReveal extends StatelessWidget {
  const SectionReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 14,
  });

  final Widget child;
  final Duration delay;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: t.motionNormal + delay,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        final eased = Curves.easeOutCubic.transform(value.clamp(0.0, 1.0));
        return Opacity(
          opacity: eased,
          child: Transform.translate(
            offset: Offset(0, (1 - eased) * offsetY),
            child: child,
          ),
        );
      },
    );
  }
}
