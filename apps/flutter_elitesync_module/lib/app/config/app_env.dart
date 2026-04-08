import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.appName,
    required this.apiBaseUrl,
    required this.useMockData,
    this.useMockAuth = false,
    this.useMockQuestionnaire = false,
    this.useMockHome = false,
    this.useMockMatch = false,
    this.useMockChat = false,
    this.useMockProfile = false,
    this.useMockAdmin = false,
    this.initialRoute,
    this.debugAccessToken = '',
    this.debugRefreshToken = '',
    this.debugAutoLoginPhone = '',
    this.debugAutoLoginPassword = '',
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
  final bool useMockAdmin;
  final String? initialRoute;
  final String debugAccessToken;
  final String debugRefreshToken;
  final String debugAutoLoginPhone;
  final String debugAutoLoginPassword;

  bool get isDev => flavor == AppFlavor.dev;
  bool get isProd => flavor == AppFlavor.prod;
}
