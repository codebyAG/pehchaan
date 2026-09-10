import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pehchaan/app.dart';

void main() {
  setUp(() {
    // hydrate() awaits SharedPreferences.getInstance() on startup — without
    // this, the platform channel call never resolves in a widget test and
    // the app stays stuck on splash forever.
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash leads straight into Home with no login gate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PehchaanApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Aaj kya promote karna hai?'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Aaj kya promote karna hai?'), findsOneWidget);
  });

  testWidgets('Home shows the pre-seeded mock business and creatives', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PehchaanApp());
    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();

    expect(find.text('Raju Tailor'), findsOneWidget);
  });
}
