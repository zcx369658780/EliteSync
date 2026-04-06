import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

void main() {
  runEliteSyncApp(
    const AppEnv(
      flavor: AppFlavor.prod,
      appName: 'EliteSync',
      // The Android host app embeds the Flutter release AAR, which always
      // boots through main.dart -> main_prod.dart. Keep prod pointed at the
      // verified direct backend entry until the public domain chain is stable.
      apiBaseUrl: 'http://101.133.161.203',
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: false,
      useMockHome: false,
      useMockMatch: false,
      useMockChat: false,
      useMockProfile: false,
    ),
  );
}
