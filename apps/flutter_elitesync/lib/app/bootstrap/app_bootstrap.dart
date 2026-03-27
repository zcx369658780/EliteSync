import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_elitesync/app/app.dart';
import 'package:flutter_elitesync/app/config/app_env.dart';
import 'package:flutter_elitesync/shared/providers/app_providers.dart';

void runEliteSyncApp(AppEnv env) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(env)],
      child: const EliteSyncApp(),
    ),
  );
}
