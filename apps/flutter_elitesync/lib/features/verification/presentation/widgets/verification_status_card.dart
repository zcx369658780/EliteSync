import 'package:flutter/material.dart';
import 'package:flutter_elitesync/design_system/components/cards/app_card.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme_extensions.dart';
import 'package:flutter_elitesync/shared/enums/verification_status.dart';

class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({
    super.key,
    required this.status,
    required this.title,
    required this.description,
  });

  final VerificationStatus status;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final t = context.appTokens;
    final (label, color) = switch (status) {
      VerificationStatus.approved => ('已通过', t.success),
      VerificationStatus.pendingReview => ('审核中', t.warning),
      VerificationStatus.rejected => ('被驳回', t.error),
      VerificationStatus.needResubmit => ('需补充材料', t.warning),
      VerificationStatus.unverified => ('未认证', t.info),
      _ => ('未知', t.textTertiary),
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: t.textSecondary)),
        ],
      ),
    );
  }
}
