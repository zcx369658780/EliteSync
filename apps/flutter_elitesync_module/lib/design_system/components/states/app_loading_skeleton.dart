import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class AppLoadingSkeleton extends StatefulWidget {
  const AppLoadingSkeleton({super.key, this.lines = 4});

  final int lines;

  @override
  State<AppLoadingSkeleton> createState() => _AppLoadingSkeletonState();
}

class _AppLoadingSkeletonState extends State<AppLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final alpha = 0.18 + (_controller.value * 0.18);
        final base = t.overlay.withValues(alpha: alpha);
        return Column(
          children: [
            for (var i = 0; i < widget.lines; i++) ...[
              Container(
                width: double.infinity,
                height: 14 + (i % 2) * 6,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(t.radius.sm),
                ),
              ),
              SizedBox(height: t.spacing.sm),
            ],
          ],
        );
      },
    );
  }
}
