import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';

class MatchHeroCard extends StatelessWidget {
  const MatchHeroCard({super.key, required this.headline, required this.score});

  final String headline;
  final int score;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(headline, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('综合匹配分：$score'),
        ],
      ),
    );
  }
}
