import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';

class RelationshipTopicCard extends StatelessWidget {
  const RelationshipTopicCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(child: Text(title));
  }
}
