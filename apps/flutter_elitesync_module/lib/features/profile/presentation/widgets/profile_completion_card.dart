import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';

class ProfileCompletionCard extends StatelessWidget {
  const ProfileCompletionCard({super.key, required this.completion});
  final double completion;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('资料完整度'),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: completion),
          const SizedBox(height: 6),
          Text('${(completion * 100).toStringAsFixed(0)}%'),
        ],
      ),
    );
  }
}
