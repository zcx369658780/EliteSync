import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_banner_entity.dart';

class HomeHeroBanner extends StatelessWidget {
  const HomeHeroBanner({super.key, required this.banner});

  final HomeBannerEntity banner;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(banner.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(banner.subtitle),
          const SizedBox(height: 12),
          Text(banner.cta, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
