import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';

enum AppTopBarMode { titleOnly, backTitle, immersive }

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.mode = AppTopBarMode.titleOnly,
    this.onBack,
    this.actions,
  });

  final String? title;
  final AppTopBarMode mode;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final canPop = Navigator.of(context).canPop();

    final bgColor = switch (mode) {
      AppTopBarMode.titleOnly => t.pageBackground,
      AppTopBarMode.backTitle => t.pageBackground,
      AppTopBarMode.immersive => Colors.transparent,
    };

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      title: Text(
        title ?? '',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: t.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      leading: mode == AppTopBarMode.backTitle && canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: onBack ?? () => Navigator.of(context).pop(),
            )
          : null,
      actions: actions,
    );
  }
}
