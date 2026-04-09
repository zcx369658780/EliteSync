import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_elitesync_module/app/router/app_route_names.dart';
import 'package:flutter_elitesync_module/design_system/components/bars/app_bottom_nav_bar.dart';
import 'package:flutter_elitesync_module/design_system/components/brand/floating_dock_bottom_bar.dart';
import 'package:flutter_elitesync_module/features/discover/presentation/pages/discover_page.dart';
import 'package:flutter_elitesync_module/features/home/presentation/pages/home_page.dart';
import 'package:flutter_elitesync_module/features/match/presentation/pages/match_portal_page.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/pages/conversation_list_page.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_elitesync_module/features/status/presentation/providers/status_posts_provider.dart';
import 'package:flutter_elitesync_module/features/chat/presentation/providers/chat_providers.dart';
import 'package:flutter_elitesync_module/features/home/presentation/providers/home_provider.dart';
import 'package:flutter_elitesync_module/features/match/presentation/providers/match_providers.dart';
import 'package:flutter_elitesync_module/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_elitesync_module/core/storage/cache_keys.dart';
import 'package:flutter_elitesync_module/shared/enums/questionnaire_status.dart';
import 'package:flutter_elitesync_module/shared/enums/verification_status.dart';
import 'package:flutter_elitesync_module/shared/providers/navigation_guard_provider.dart';
import 'package:flutter_elitesync_module/shared/providers/app_providers.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  bool _warmed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _warmupProviders();
    });
  }

  Future<void> _warmupProviders() async {
    if (_warmed) return;
    _warmed = true;
    final lite =
        await ref
            .read(localStorageProvider)
            .getBool(CacheKeys.performanceLiteMode) ??
        false;
    if (lite) return;

    final initialRoute = (ref.read(appEnvProvider).initialRoute ?? '').trim();
    final targets = <Future<void>>[];

    void warm(Future<dynamic> future) {
      targets.add(future.then((_) {}));
    }

    // 只预热当前首进页相关 provider，避免一次性 warm 过多链路拉高启动负担。
    if (initialRoute.startsWith(AppRouteNames.messages)) {
      warm(ref.read(conversationListProvider.future));
    } else if (initialRoute.startsWith(AppRouteNames.match)) {
      warm(ref.read(matchCountdownProvider.future));
      warm(ref.read(matchResultProvider.future));
    } else if (initialRoute.startsWith(AppRouteNames.statusSquare)) {
      warm(ref.read(statusPostsProvider.future));
    } else if (initialRoute.startsWith(AppRouteNames.profile)) {
      warm(ref.read(profileProvider.future));
    } else {
      warm(ref.read(homeProvider.future));
    }

    try {
      await Future.wait(targets);
    } catch (_) {
      // warmup 失败不应阻塞主链路；页面本身仍会按各自 provider 兜底。
    }
  }

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      extendBody: true,
      bottomNavigationBar: FloatingDockBottomBar(
        currentIndex: widget.navigationShell.currentIndex,
        onTap: _onTap,
        browseMode: widget.navigationShell.currentIndex != 2,
        centerActionLabel: '发布状态',
        onCenterActionTap: () => context.push(AppRouteNames.statusSquare),
        items: const [
          AppBottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: '首页',
          ),
          AppBottomNavItem(
            icon: Icons.explore_outlined,
            activeIcon: Icons.explore_rounded,
            label: '发现',
          ),
          AppBottomNavItem(
            icon: Icons.auto_awesome_outlined,
            activeIcon: Icons.auto_awesome,
            label: '匹配',
          ),
          AppBottomNavItem(
            icon: Icons.chat_bubble_outline,
            activeIcon: Icons.chat_bubble,
            label: '消息',
          ),
          AppBottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: '我的',
          ),
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
    final env = ref.watch(appEnvProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      if (nav.isBootstrapLoading) return;

      if (!nav.isLoggedIn) {
        context.go(AppRouteNames.login);
        return;
      }

      if (nav.verificationStatus != VerificationStatus.approved) {
        context.go(AppRouteNames.verificationStatus);
        return;
      }

      if (nav.questionnaireStatus != QuestionnaireStatus.completed) {
        context.go(AppRouteNames.questionnaire);
        return;
      }

      context.go(env.initialRoute ?? AppRouteNames.home);
    });

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF081221), Color(0xFF0C1B31), Color(0xFF122643)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2.5),
              SizedBox(height: 12),
              Text('正在进入慢约会…', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
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
  Widget build(BuildContext context) => const MatchPortalPage();
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
