import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync/app/app.dart';
import 'package:flutter_elitesync/app/config/app_env.dart';
import 'package:flutter_elitesync/app/config/app_flavor.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

void main() {
  testWidgets('App boots with splash placeholder', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appEnvProvider.overrideWithValue(
            const AppEnv(
              flavor: AppFlavor.dev,
              appName: 'EliteSync Dev',
              apiBaseUrl: 'http://101.133.161.203',
              useMockData: true,
            ),
          ),
        ],
        child: const EliteSyncApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Splash 占位页（后续接入启动分流）。'), findsOneWidget);
  });
}
