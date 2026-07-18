
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitbook_desktop/main.dart';

void main() {
  testWidgets('Unauthenticated app start shows the login screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FitBookDesktopApp());
    await tester.pumpAndSettle();

    expect(find.text('FitBook'), findsOneWidget);
    expect(find.text('Prijava administratora'), findsOneWidget);
    expect(find.text('Prijavi se'), findsOneWidget);
  });

  testWidgets('Submitting the login form empty shows validation messages', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const FitBookDesktopApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Prijavi se'));
    await tester.pumpAndSettle();

    expect(find.text('Korisničko ime je obavezno.'), findsOneWidget);
    expect(find.text('Lozinka je obavezna.'), findsOneWidget);
  });
}
