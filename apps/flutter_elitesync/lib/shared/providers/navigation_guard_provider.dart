import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/shared/enums/auth_status.dart';
import 'package:flutter_elitesync/shared/enums/match_status.dart';
import 'package:flutter_elitesync/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync/shared/enums/verification_status.dart';
import 'package:flutter_elitesync/shared/models/navigation_snapshot.dart';
import 'package:flutter_elitesync/shared/providers/session_provider.dart';

final navigationGuardProvider = Provider<NavigationSnapshot>((ref) {
  final auth = ref.watch(authStatusProvider);

  final verificationStatus = auth == AuthStatus.authenticated
      ? VerificationStatus.approved
      : VerificationStatus.unverified;

  final questionnaireStatus = auth == AuthStatus.authenticated
      ? QuestionnaireStatus.completed
      : QuestionnaireStatus.notStarted;

  final matchStatus = auth == AuthStatus.authenticated
      ? MatchStatus.revealed
      : MatchStatus.unknown;

  final canChat = auth == AuthStatus.authenticated;

  return NavigationSnapshot(
    authStatus: auth,
    verificationStatus: verificationStatus,
    questionnaireStatus: questionnaireStatus,
    matchStatus: matchStatus,
    canChat: canChat,
    isBootstrapLoading: auth == AuthStatus.unknown,
  );
});
