import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/core/ui/app_motion.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

enum AppFeedbackType { success, error, info }

class AppFeedback {
  const AppFeedback._();

  static void showSuccess(BuildContext context, String message) {
    _show(context, message, AppFeedbackType.success);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, AppFeedbackType.error);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, AppFeedbackType.info);
  }

  static void _show(
    BuildContext context,
    String message,
    AppFeedbackType type,
  ) {
    final t = context.appTokens;
    final (bg, icon) = switch (type) {
      AppFeedbackType.success => (t.success.withValues(alpha: 0.9), Icons.check_circle_rounded),
      AppFeedbackType.error => (t.error.withValues(alpha: 0.9), Icons.error_rounded),
      AppFeedbackType.info => (t.brandPrimary.withValues(alpha: 0.9), Icons.info_rounded),
    };

    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          duration: AppMotion.feedbackDuration,
          backgroundColor: bg,
          margin: EdgeInsets.fromLTRB(
            t.spacing.md,
            t.spacing.sm,
            t.spacing.md,
            t.spacing.lg,
          ),
          content: Row(
            children: [
              Icon(icon, size: 16, color: Colors.white),
              SizedBox(width: t.spacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
