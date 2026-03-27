import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';

class MatchSummaryCard extends StatelessWidget {
  const MatchSummaryCard({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(text));
  }
}
