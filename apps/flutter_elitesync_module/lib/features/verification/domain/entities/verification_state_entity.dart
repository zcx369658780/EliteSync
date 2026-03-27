import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';

class VerificationStateEntity {
  const VerificationStateEntity({
    required this.status,
    required this.title,
    required this.description,
  });

  final VerificationStatus status;
  final String title;
  final String description;
}
