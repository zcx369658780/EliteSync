import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

class ImmersiveAuthBackground extends StatefulWidget {
  const ImmersiveAuthBackground({super.key, required this.child});

  final Widget child;

  @override
  State<ImmersiveAuthBackground> createState() => _ImmersiveAuthBackgroundState();
}

class _ImmersiveAuthBackgroundState extends State<ImmersiveAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
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
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(-0.35 + _controller.value * 0.1, -0.85),
              radius: 1.15,
              colors: [
                t.brandSecondary.withValues(alpha: 0.32),
                t.brandPrimary.withValues(alpha: 0.18),
                t.pageBackground,
                const Color(0xFF060A17),
              ],
              stops: const [0.0, 0.28, 0.72, 1.0],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(
                painter: _StarFieldPainter(
                  progress: _controller.value,
                  starColor: t.textPrimary.withValues(alpha: 0.9),
                ),
              ),
              child!,
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter({required this.progress, required this.starColor});

  final double progress;
  final Color starColor;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(20260326);
    final count = (size.width * size.height / 4200).round().clamp(120, 260);

    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final seed = random.nextDouble();
      final twinkle = (math.sin((progress * 2 * math.pi) + seed * 8) + 1) / 2;
      final radius = 0.5 + random.nextDouble() * 1.6;
      final alpha = (0.22 + twinkle * 0.72).clamp(0.0, 1.0);

      final paint = Paint()..color = starColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.starColor != starColor;
  }
}

