import 'package:flutter/material.dart';
import 'package:flutter_elitesync_module/design_system/components/cards/app_card.dart';

class VerificationRequirementCard extends StatelessWidget {
  const VerificationRequirementCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('认证要求'),
          SizedBox(height: 8),
          Text('• 使用真实姓名\n• 填写有效身份证号\n• 提交后通常 1-3 天审核'),
        ],
      ),
    );
  }
}
