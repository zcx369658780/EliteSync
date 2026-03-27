import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class ImmersiveAuthBackground extends StatefulWidget {
  const ImmersiveAuthBackground({
    super.key,
    required this.child,
    this.performanceLiteMode = false,
  });

  final Widget child;
  final bool performanceLiteMode;

  @override
  State<ImmersiveAuthBackground> createState() => _ImmersiveAuthBackgroundState();
}

class _ImmersiveAuthBackgroundState extends State<ImmersiveAuthBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
  )..repeat(reverse: true);
  bool _pausedForKeyboard = false;

  void _syncAnimation(bool pause) {
    if (pause == _pausedForKeyboard) return;
    _pausedForKeyboard = pause;
    if (pause) {
      _controller.stop(canceled: false);
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final keyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    _syncAnimation(keyboardVisible || widget.performanceLiteMode);
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
                  progress: (keyboardVisible || widget.performanceLiteMode) ? 0.35 : _controller.value,
                  starColor: t.textPrimary.withValues(alpha: 0.9),
                  performanceLiteMode: widget.performanceLiteMode,
                ),
              ),
              RepaintBoundary(child: child!),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _StarFieldPainter extends CustomPainter {
  const _StarFieldPainter({
    required this.progress,
    required this.starColor,
    required this.performanceLiteMode,
  });

  final double progress;
  final Color starColor;
  final bool performanceLiteMode;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(20260326);
    final count = performanceLiteMode
        ? (size.width * size.height / 9000).round().clamp(40, 90)
        : (size.width * size.height / 5200).round().clamp(80, 160);

    for (var i = 0; i < count; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final seed = random.nextDouble();
      final twinkle = (math.sin((progress * 2 * math.pi) + seed * 8) + 1) / 2;
      final radius = 0.5 + random.nextDouble() * 1.6;
      final alpha = performanceLiteMode
          ? (0.28 + twinkle * 0.38).clamp(0.0, 1.0)
          : (0.22 + twinkle * 0.72).clamp(0.0, 1.0);

      final paint = Paint()..color = starColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StarFieldPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.starColor != starColor ||
        oldDelegate.performanceLiteMode != performanceLiteMode;
  }
}
