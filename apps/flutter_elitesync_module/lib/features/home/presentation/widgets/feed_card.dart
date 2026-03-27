import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';

class FeedCard extends StatelessWidget {
  const FeedCard({super.key, required this.item});

  final HomeFeedEntity item;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(item.summary),
          const SizedBox(height: 10),
          Text('${item.author} · ${item.likes} 喜欢', style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}
