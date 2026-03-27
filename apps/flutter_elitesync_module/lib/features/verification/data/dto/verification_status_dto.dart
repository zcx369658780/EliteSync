import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';

class VerificationStatusDto {
  const VerificationStatusDto({
    required this.status,
    required this.title,
    required this.description,
  });

  final VerificationStatus status;
  final String title;
  final String description;

  factory VerificationStatusDto.fromJson(Map<String, dynamic> json) {
    final raw = (json['status'] as String?) ?? 'unverified';
    final status = switch (raw) {
      'pending' => VerificationStatus.pendingReview,
      'approved' => VerificationStatus.approved,
      'rejected' => VerificationStatus.rejected,
      'need_resubmit' => VerificationStatus.needResubmit,
      _ => VerificationStatus.unverified,
    };

    return VerificationStatusDto(
      status: status,
      title: (json['title'] as String?) ?? '实名认证',
      description: (json['description'] as String?) ?? '请完成实名认证后继续',
    );
  }
}

