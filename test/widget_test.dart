import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pehchaan/app.dart';

void main() {
  testWidgets('Splash leads straight into Home with no login gate', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const PehchaanApp());
    await tester.pump(const Duration(milliseconds: 1300));

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

    expect(find.text('Raju Tailor'), findsOneWidget);
  });
}
