import 'package:flutter/material.dart';

class AppMotion {
  const AppMotion._();

  static const Duration routeForward = Duration(milliseconds: 280);
  static const Duration routeReverse = Duration(milliseconds: 220);
  static const Duration feedbackDuration = Duration(milliseconds: 1200);

  static const Curve routeCurve = Curves.easeOutCubic;
  static const Curve routeReverseCurve = Curves.easeInCubic;
  static const Curve standardCurve = Curves.easeOutCubic;
}

