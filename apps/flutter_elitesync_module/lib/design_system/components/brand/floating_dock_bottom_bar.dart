import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_bottom_nav_bar.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class FloatingDockBottomBar extends StatelessWidget {
  const FloatingDockBottomBar({
    super.key,
    required this.currentIndex,
    required this.items,
    required this.onTap,
    this.browseMode = true,
    this.centerActionLabel,
    this.onCenterActionTap,
  });

  final int currentIndex;
  final List<AppBottomNavItem> items;
  final ValueChanged<int> onTap;
  final bool browseMode;
  final String? centerActionLabel;
  final VoidCallback? onCenterActionTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final centerEnabled = (centerActionLabel ?? '').isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: SizedBox(
          height: centerEnabled ? 82 : 72,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                      decoration: BoxDecoration(
                        color: (browseMode ? t.browseNav : t.surface).withValues(alpha: 0.86),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: t.browseBorder.withValues(alpha: 0.9)),
                      ),
                      child: Row(
                        children: [
                          for (var i = 0; i < items.length; i++)
                            Expanded(
                              child: _DockItem(
                                item: items[i],
                                selected: i == currentIndex,
                                onTap: () => onTap(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (centerEnabled)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: onCenterActionTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: LinearGradient(
                            colors: [
                              t.brandPrimary.withValues(alpha: 0.95),
                              t.brandSecondary.withValues(alpha: 0.92),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: t.brandPrimary.withValues(alpha: 0.28),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.auto_awesome_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              centerActionLabel!,
                              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final icon = selected ? (item.activeIcon ?? item.icon) : item.icon;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: t.motionFast,
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: selected ? t.brandPrimary.withValues(alpha: 0.16) : Colors.transparent,
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: t.brandPrimary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: selected ? t.brandPrimary : t.textSecondary),
            const SizedBox(height: 1),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.fade,
              softWrap: false,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: selected ? t.textPrimary : t.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 10.5,
                    height: 1.0,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
