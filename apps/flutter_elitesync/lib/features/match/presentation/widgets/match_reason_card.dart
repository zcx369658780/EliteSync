import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';

class MatchReasonCard extends StatelessWidget {
  const MatchReasonCard({super.key, required this.reason});
  final String reason;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(reason));
  }
}
