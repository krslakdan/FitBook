// Basic smoke test: the provider layer wires up and the app renders without
// throwing. Real screen tests arrive with the screens phase.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitbook_desktop/main.dart';

void main() {
  testWidgets('App starts and shows the unauthenticated placeholder', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FitBookDesktopApp());
    await tester.pumpAndSettle();

    expect(find.text('FitBook Desktop'), findsOneWidget);
    expect(find.textContaining('Niste prijavljeni'), findsOneWidget);
  });
}
