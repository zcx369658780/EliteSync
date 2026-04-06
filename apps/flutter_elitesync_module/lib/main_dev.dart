import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

void main() {
  runEliteSyncApp(
    AppEnv(
      flavor: AppFlavor.dev,
      appName: 'EliteSync Dev',
      apiBaseUrl: 'http://101.133.161.203',
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: true,
      useMockHome: false,
      useMockMatch: true,
      useMockChat: const bool.fromEnvironment('ELITESYNC_CHAT_MOCK'),
      useMockProfile: false,
      useMockAdmin: const bool.fromEnvironment('ELITESYNC_ADMIN_MOCK'),
      initialRoute: String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim().isEmpty
          ? null
          : String.fromEnvironment('ELITESYNC_INITIAL_ROUTE').trim(),
    ),
  );
}
