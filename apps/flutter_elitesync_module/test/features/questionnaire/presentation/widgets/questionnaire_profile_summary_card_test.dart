import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync_module/design_system/theme/app_theme.dart';
import 'package:flutter_elitesync_module/features/questionnaire/domain/entities/questionnaire_profile_snapshot.dart';
import 'package:flutter_elitesync_module/features/questionnaire/presentation/widgets/questionnaire_profile_summary_card.dart';

void main() {
  testWidgets(
    'questionnaire profile summary card renders summary and actions',
    (tester) async {
      const snapshot = QuestionnaireProfileSnapshot(
        questionnaireVersion: 'q_v2',
        bankVersion: 'qb_v1',
        attemptVersion: 'qa_v1',
        label: '倾向：attachment_security + communication_clarity',
        highlights: ['attachment_security 56', 'communication_clarity 63'],
        complete: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: Scaffold(
            body: QuestionnaireProfileSummaryCard(
              snapshot: snapshot,
              onViewHistory: () {},
              onContinueQuestionnaire: () {},
            ),
          ),
        ),
      );

      expect(find.text('问卷倾向已同步'), findsOneWidget);
      expect(find.text('q_v2 / qb_v1 / qa_v1'), findsOneWidget);
      expect(find.text(snapshot.label), findsOneWidget);
      expect(find.textContaining('attachment_security 56'), findsOneWidget);
      expect(find.textContaining('communication_clarity 63'), findsOneWidget);
      expect(find.text('查看历史记录'), findsOneWidget);
      expect(find.text('重新作答'), findsOneWidget);
    },
  );
}
