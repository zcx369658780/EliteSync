import 'package:flutter_elitesync/shared/enums/auth_status.dart';
import 'package:flutter_elitesync/shared/enums/match_status.dart';
import 'package:flutter_elitesync/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync/shared/enums/verification_status.dart';

class NavigationSnapshot {
  const NavigationSnapshot({
    required this.authStatus,
    required this.verificationStatus,
    required this.questionnaireStatus,
    required this.matchStatus,
    required this.canChat,
    required this.isBootstrapLoading,
  });

  final AuthStatus authStatus;
  final VerificationStatus verificationStatus;
  final QuestionnaireStatus questionnaireStatus;
  final MatchStatus matchStatus;
  final bool canChat;
  final bool isBootstrapLoading;

  bool get isLoggedIn => authStatus == AuthStatus.authenticated;
}
