import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_elitesync_module/app/bootstrap/app_bootstrap.dart';
import 'package:flutter_elitesync_module/app/config/app_env.dart';
import 'package:flutter_elitesync_module/app/config/app_flavor.dart';

Future<Map<String, String>> _readHostBootstrap() async {
  try {
    const channel = MethodChannel('elitesync/bootstrap');
    final payload = await channel.invokeMapMethod<dynamic, dynamic>(
      'getBootstrap',
    );
    if (payload == null) return const {};
    return payload.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  } catch (_) {
    return const {};
  }
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) return trimmed;
  }
  return '';
}

String _resolveApiBaseUrl({required Map<String, String> hostBootstrap}) {
  final hostOverride = _firstNonEmpty([hostBootstrap['apiBaseUrl'] ?? '']);
  if (hostOverride.isNotEmpty) {
    return hostOverride.endsWith('/') ? hostOverride : '$hostOverride/';
  }
  final override = String.fromEnvironment('ELITESYNC_API_BASE_URL').trim();
  if (override.isNotEmpty) {
    return override.endsWith('/') ? override : '$override/';
  }
  return 'http://101.133.161.203/';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hostBootstrap = await _readHostBootstrap();
  final initialRoute = _firstNonEmpty([
    String.fromEnvironment('ELITESYNC_INITIAL_ROUTE'),
    hostBootstrap['initialRoute'] ?? '',
  ]);

  // ignore: avoid_print
  print(
    'MAIN_PROD_BOOTSTRAP initialRoute=${initialRoute.isNotEmpty ? initialRoute : "null"} flavor=prod',
  );

  runEliteSyncApp(
    AppEnv(
      flavor: AppFlavor.prod,
      appName: 'EliteSync',
      // The Android host app embeds the Flutter release AAR, which always
      // boots through main.dart -> main_prod.dart. Keep prod pointed at the
      // verified direct backend entry until the public domain chain is stable.
      apiBaseUrl: _resolveApiBaseUrl(hostBootstrap: hostBootstrap),
      useMockData: false,
      useMockAuth: false,
      useMockQuestionnaire: false,
      useMockHome: false,
      useMockMatch: false,
      useMockChat: false,
      useMockProfile: false,
      useMockAdmin: false,
      initialRoute: initialRoute.isEmpty ? null : initialRoute,
    ),
  );
}
