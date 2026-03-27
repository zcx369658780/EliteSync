import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/tokens/app_colors.dart';

abstract final class AppGradients {
  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF69B3FF), Color(0xFF7F8BFF)],
  );

  static const LinearGradient match = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5FE1C8), Color(0xFF5AA8FF)],
  );

  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101B35), Color(0xFF172A52)],
  );

  static const LinearGradient soft = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEAF4FF), Color(0xFFF1EEFF)],
  );

  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.darkBg, AppColors.darkSurface],
  );
}
