import 'dart:math' as math;

import 'package:flutter/material.dart';

class ConstellationHeroCanvas extends StatelessWidget {
  const ConstellationHeroCanvas({super.key, this.opacity = 1});

  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ConstellationPainter(opacity: opacity),
      size: Size.infinite,
    );
  }
}

class _ConstellationPainter extends CustomPainter {
  const _ConstellationPainter({required this.opacity});

  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(2603);
    final starPaint = Paint()..style = PaintingStyle.fill;
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9
      ..color = Colors.white.withValues(alpha: 0.24 * opacity);

    final points = <Offset>[];
    final total = (size.width * size.height / 3500).round().clamp(150, 340);
    for (var i = 0; i < total; i++) {
      final p = Offset(random.nextDouble() * size.width, random.nextDouble() * size.height);
      points.add(p);
      starPaint.color = Colors.white.withValues(alpha: (0.25 + random.nextDouble() * 0.75) * opacity);
      canvas.drawCircle(p, 0.6 + random.nextDouble() * 1.9, starPaint);
    }

    for (var i = 0; i < points.length; i += 7) {
      if (i + 1 < points.length) {
        canvas.drawLine(points[i], points[i + 1], linePaint);
      }
      if (i + 3 < points.length && random.nextBool()) {
        canvas.drawLine(points[i + 1], points[i + 3], linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter oldDelegate) {
    return oldDelegate.opacity != opacity;
  }
}

