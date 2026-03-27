import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_secondary_button.dart';

class MatchIntentionActionBar extends StatelessWidget {
  const MatchIntentionActionBar({
    super.key,
    required this.onAccept,
    required this.onLater,
  });

  final VoidCallback onAccept;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: AppPrimaryButton(label: '愿意认识', onPressed: onAccept)),
        const SizedBox(width: 10),
        Expanded(
          child: AppSecondaryButton(
            label: '稍后决定',
            onPressed: onLater,
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
