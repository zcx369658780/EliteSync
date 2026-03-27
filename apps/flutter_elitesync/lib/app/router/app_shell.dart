import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync/app/router/app_route_names.dart';
import 'package:flutter_elitesync/design_system/components/bars/app_bottom_nav_bar.dart';
import 'package:flutter_elitesync/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync/features/discover/presentation/pages/discover_page.dart';
import 'package:flutter_elitesync/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync/features/match/presentation/pages/match_result_page.dart';
import 'package:flutter_elitesync/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_elitesync/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync/shared/enums/verification_status.dart';
import 'package:flutter_elitesync/shared/providers/navigation_guard_provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      extendBody: true,
      bottomNavigationBar: FloatingDockBottomBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        browseMode: navigationShell.currentIndex != 2,
        centerActionLabel: '速配',
        onCenterActionTap: () => _onTap(2),
        items: const [
          AppBottomNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: '首页'),
          AppBottomNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: '发现'),
          AppBottomNavItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: '匹配'),
          AppBottomNavItem(icon: Icons.chat_bubble_outline, activeIcon: Icons.chat_bubble, label: '消息'),
          AppBottomNavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: '我的'),
        ],
      ),
    );
  }
}

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.watch(navigationGuardProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (nav.isBootstrapLoading) return;

      if (!nav.isLoggedIn) {
        context.go(AppRouteNames.login);
        return;
      }

      if (nav.verificationStatus !=
          VerificationStatus.approved) {
        context.go(AppRouteNames.verificationStatus);
        return;
      }

      if (nav.questionnaireStatus != QuestionnaireStatus.completed) {
        context.go(AppRouteNames.questionnaire);
        return;
      }

      context.go(AppRouteNames.home);
    });

    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class HomeShellPage extends StatelessWidget {
  const HomeShellPage({super.key});

  @override
  Widget build(BuildContext context) => const HomePage();
}

class MatchShellPage extends StatelessWidget {
  const MatchShellPage({super.key});

  @override
  Widget build(BuildContext context) => const MatchResultPage();
}

class DiscoverShellPage extends StatelessWidget {
  const DiscoverShellPage({super.key});

  @override
  Widget build(BuildContext context) => const DiscoverPage();
}

class MessagesShellPage extends StatelessWidget {
  const MessagesShellPage({super.key});

  @override
  Widget build(BuildContext context) => const ConversationListPage();
}

class ProfileShellPage extends StatelessWidget {
  const ProfileShellPage({super.key});

  @override
  Widget build(BuildContext context) => const ProfilePage();
}
