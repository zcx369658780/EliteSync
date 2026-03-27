import 'package:flutter_elitesync/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync/app/config/app_env.dart';
import 'package:flutter_elitesync/app/config/app_flavor.dart';

void main() {
  runEliteSyncApp(
    const AppEnv(
      flavor: AppFlavor.dev,
      appName: 'EliteSync Dev',
      apiBaseUrl: 'http://101.133.161.203',
      useMockData: true,
      useMockAuth: true,
      useMockQuestionnaire: true,
      useMockHome: true,
      useMockMatch: true,
      useMockChat: true,
      useMockProfile: true,
    ),
  );
}
