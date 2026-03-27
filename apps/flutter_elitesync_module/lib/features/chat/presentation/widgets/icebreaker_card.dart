import 'package:flutter/material.dart';

class IcebreakerCard extends StatelessWidget {
  const IcebreakerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text('破冰建议：先聊聊最近一次让你放松的周末安排。'),
      ),
    );
  }
}
