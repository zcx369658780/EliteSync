import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_elitesync/design_system/components/buttons/app_primary_button.dart';
import 'package:flutter_elitesync/design_system/components/fields/app_text_field.dart';
import 'package:flutter_elitesync/design_system/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(theme: AppTheme.light, darkTheme: AppTheme.dark, home: Scaffold(body: child));
}

void main() {
  testWidgets('AppPrimaryButton renders and taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(AppPrimaryButton(label: '确认', onPressed: () => tapped = true)));
    await tester.tap(find.text('确认'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('AppTextField displays label and hint', (tester) async {
    await tester.pumpWidget(_wrap(const AppTextField(label: '手机号', hint: '请输入')));
    expect(find.text('手机号'), findsOneWidget);
    expect(find.text('请输入'), findsOneWidget);
  });
}
