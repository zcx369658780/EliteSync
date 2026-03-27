import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/constellation_hero_canvas.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme_extensions.dart';

class ProfileGlassHeaderCard extends StatelessWidget {
  const ProfileGlassHeaderCard({
    super.key,
    required this.nickname,
    required this.city,
    required this.verified,
  });

  final String nickname;
  final String city;
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(t.radius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            t.brandSecondary.withValues(alpha: 0.40),
            t.brandPrimary.withValues(alpha: 0.30),
            t.surface.withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: t.overlay.withValues(alpha: 0.75)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(t.radius.xl),
        child: Stack(
          children: [
            const Positioned.fill(child: ConstellationHeroCanvas(opacity: 0.7)),
            Container(color: Colors.black.withValues(alpha: 0.10)),
            Padding(
              padding: EdgeInsets.all(t.spacing.cardPaddingLarge),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: t.brandPrimary.withValues(alpha: 0.24),
                    child: Icon(Icons.person_rounded, color: t.textPrimary, size: 32),
                  ),
                  SizedBox(width: t.spacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nickname,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: t.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(city, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: (verified ? t.success : t.warning).withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      verified ? '已认证' : '未认证',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: verified ? t.success : t.warning,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

