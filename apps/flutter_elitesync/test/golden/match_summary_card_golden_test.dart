import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync/features/match/presentation/widgets/match_summary_card.dart';

void main() {
  testWidgets('MatchSummaryCard golden', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(body: MatchSummaryCard(text: '综合匹配度 86 分')),
      ),
    );

    await expectLater(
      find.byType(MatchSummaryCard),
      matchesGoldenFile('goldens/match_summary_card.png'),
    );
  });
}
