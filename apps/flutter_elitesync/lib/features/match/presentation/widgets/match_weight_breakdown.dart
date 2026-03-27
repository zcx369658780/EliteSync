import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';

class MatchWeightBreakdown extends StatelessWidget {
  const MatchWeightBreakdown({super.key, required this.weights});
  final Map<String, int> weights;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: weights.entries.map((e) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text('${e.key}: ${e.value}%'),
        )).toList(),
      ),
    );
  }
}
