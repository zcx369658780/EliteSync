import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.useMockData,
    this.useMockAuth = true,
    this.useMockQuestionnaire = true,
    this.useMockHome = true,
    this.useMockMatch = true,
    this.useMockChat = true,
    this.useMockProfile = true,
  });

  final AppFlavor flavor;
  final String appName;
  final String apiBaseUrl;
  final bool useMockData;
  final bool useMockAuth;
  final bool useMockQuestionnaire;
  final bool useMockHome;
  final bool useMockMatch;
  final bool useMockChat;
  final bool useMockProfile;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
