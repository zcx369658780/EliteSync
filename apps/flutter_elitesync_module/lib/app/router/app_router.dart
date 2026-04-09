import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/app/router/app_route_observer.dart';
import 'package:flutter_elitesync_module/app/router/app_shell.dart';
import 'package:flutter_elitesync_module/core/ui/app_motion.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_moderation_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_report_detail_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_verification_page.dart';
import 'package:flutter_elitesync_module/features/admin/presentation/pages/admin_users_page.dart';
import 'package:flutter_elitesync_module/features/auth/presentation/pages/register_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/chat_room_page.dart';
import 'package:flutter_elitesync_module/features/home/domain/entities/home_feed_entity.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/content_detail_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_countdown_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_detail_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_intention_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_feedback_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_result_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_bazi_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_natal_chart_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_overview_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_profile_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_chart_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/astro_ziwei_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/mbti_center_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/about_update_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/change_password_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/privacy_settings_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/settings_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_page.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/pages/questionnaire_result_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_status_page.dart';
import 'package:flutter_elitesync_module/features/verification/presentation/pages/verification_submit_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/pages/status_square_page.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  ref.watch(navigationGuardProvider);
  final routeObserver = ref.watch(appRouteObserverProvider);

  final env = ref.read(appEnvProvider);
  return GoRouter(
    observers: [routeObserver],
    initialLocation: env.initialRoute ?? AppRouteNames.splash,
    redirect: (context, state) {
      final nav = ref.read(navigationGuardProvider);
      final path = state.uri.path;
      final isAuthPage =
          path == AppRouteNames.login || path == AppRouteNames.register;
      final isPublic = path == AppRouteNames.splash || isAuthPage;

      if (nav.isBootstrapLoading) return AppRouteNames.splash;

      if (!nav.isLoggedIn && !isPublic) {
        return AppRouteNames.login;
      }

      if (nav.isLoggedIn && isAuthPage) {
        return AppRouteNames.home;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRouteNames.splash,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SplashPage()),
      ),
      GoRoute(
        path: AppRouteNames.login,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const LoginPage()),
      ),
      GoRoute(
        path: AppRouteNames.register,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const RegisterPage()),
      ),
      GoRoute(
        path: AppRouteNames.verificationStatus,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const VerificationStatusPage()),
      ),
      GoRoute(
        path: AppRouteNames.verificationSubmit,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const VerificationSubmitPage()),
      ),
      GoRoute(
        path: AppRouteNames.questionnaire,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const QuestionnairePage()),
      ),
      GoRoute(
        path: AppRouteNames.questionnaireResult,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const QuestionnaireResultPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchCountdown,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchCountdownPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchResult,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchResultPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchDetail,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchDetailPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchIntention,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchIntentionPage()),
      ),
      GoRoute(
        path: AppRouteNames.matchFeedback,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MatchFeedbackPage()),
      ),
      GoRoute(
        path: '${AppRouteNames.chatRoom}/:conversationId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['conversationId'] ?? '';
          final title = (state.extra as String?) ?? '聊天';
          return _fadeSlidePage(
            state,
            ChatRoomPage(conversationId: id, title: title),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.statusSquare,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const StatusSquarePage()),
      ),
      GoRoute(
        path: '${AppRouteNames.contentDetail}/:contentId',
        pageBuilder: (context, state) {
          final id = state.pathParameters['contentId'] ?? '';
          final extra = state.extra;
          final content = extra is HomeFeedEntity ? extra : null;
          return _fadeSlidePage(
            state,
            ContentDetailPage(contentId: id, content: content),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.editProfile,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const EditProfilePage()),
      ),
      GoRoute(
        path: AppRouteNames.astroOverview,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroOverviewPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroBazi,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroBaziPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroNatalChart,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroNatalChartPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroChartSettings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroChartSettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroZiwei,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroZiweiPage()),
      ),
      GoRoute(
        path: AppRouteNames.settings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const SettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.changePassword,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const ChangePasswordPage()),
      ),
      GoRoute(
        path: AppRouteNames.privacySettings,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const PrivacySettingsPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminDashboard,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminDashboardPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminModeration,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminModerationPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminVerification,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminVerificationPage()),
      ),
      GoRoute(
        path: AppRouteNames.adminUsers,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AdminUsersPage()),
      ),
      GoRoute(
        path: '${AppRouteNames.adminModerationReportDetail}/:reportId',
        pageBuilder: (context, state) {
          final reportId =
              int.tryParse(state.pathParameters['reportId'] ?? '') ?? 0;
          return _fadeSlidePage(
            state,
            AdminReportDetailPage(reportId: reportId),
          );
        },
      ),
      GoRoute(
        path: AppRouteNames.aboutUpdate,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AboutUpdatePage()),
      ),
      GoRoute(
        path: AppRouteNames.mbtiCenter,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const MbtiCenterPage()),
      ),
      GoRoute(
        path: AppRouteNames.astroProfile,
        pageBuilder: (context, state) =>
            _fadeSlidePage(state, const AstroProfilePage()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.home,
                builder: (context, state) => const HomeShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.discover,
                builder: (context, state) => const DiscoverShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.match,
                builder: (context, state) => const MatchShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.messages,
                builder: (context, state) => const MessagesShellPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRouteNames.profile,
                builder: (context, state) => const ProfileShellPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

CustomTransitionPage<void> _fadeSlidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.routeForward,
    reverseTransitionDuration: AppMotion.routeReverse,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: AppMotion.routeCurve,
        reverseCurve: AppMotion.routeReverseCurve,
      );
      return FadeTransition(
        opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curved),
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.05),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}
