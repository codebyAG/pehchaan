import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pehchaan/core/api/models.dart';
import 'package:pehchaan/features/onboarding/language_select_screen.dart';

void main() {
  testWidgets('Language picker shows both labels and returns the code', (
    WidgetTester tester,
  ) async {
    String? chosen;
    await tester.pumpWidget(
      MaterialApp(
        home: LanguageSelectScreen(
          languages: Language.bundled,
          initial: 'hi',
          onContinue: (code) => chosen = code,
        ),
      ),
    );

    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('Hindi'), findsOneWidget);
    expect(find.text('मराठी'), findsOneWidget);

    await tester.tap(find.text('मराठी'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    expect(chosen, 'mr');
  });

  testWidgets('Language picker falls back to the bundled list when empty', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LanguageSelectScreen(languages: const [], onContinue: (_) {}),
      ),
    );
    expect(find.text('English'), findsOneWidget);
  });
}
