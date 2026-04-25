import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/rtc/presentation/widgets/rtc_audio_spectrum_bar.dart';

void main() {
  testWidgets('RtcAudioSpectrumBar shows waiting state without track', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        home: const Scaffold(
          body: RtcAudioSpectrumBar(audioTrack: null),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('等待远端音轨…'), findsOneWidget);
    expect(find.byType(RtcAudioSpectrumBar), findsOneWidget);
  });
}
