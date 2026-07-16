import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:fitbook_desktop/layouts/master_screen.dart';
import 'package:fitbook_desktop/providers/auth_provider.dart';

void main() {
  Future<void> pumpMasterScreen(WidgetTester tester, {required Size windowSize}) async {
    tester.view.physicalSize = windowSize;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const MaterialApp(
          home: MasterScreen(title: 'Dashboard', child: Center(child: Text('Sadržaj'))),
        ),
      ),
    );
  }

  testWidgets('Sidebar shows brand header, sections and pinned logout on a tall window', (
    WidgetTester tester,
  ) async {
    await pumpMasterScreen(tester, windowSize: const Size(1280, 720));

    expect(tester.takeException(), isNull);
    expect(find.text('FitBook'), findsOneWidget);
    expect(find.text('Admin Panel'), findsOneWidget);
    expect(find.text('UPRAVLJANJE'), findsOneWidget);
    expect(find.text('Odjava'), findsOneWidget);
    expect(find.text('Sadržaj'), findsOneWidget);
  });

  testWidgets('Sidebar scrolls on a small window and logout stays pinned', (
    WidgetTester tester,
  ) async {
    await pumpMasterScreen(tester, windowSize: const Size(900, 400));

    // No overflow errors even though all sections can't fit in 400px.
    expect(tester.takeException(), isNull);

    expect(find.text('Odjava').hitTestable(), findsOneWidget);
    expect(find.text('Izvještaji').hitTestable(), findsNothing);

    await tester.drag(find.text('Korisnici'), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Izvještaji').hitTestable(), findsOneWidget);
    expect(find.text('Odjava').hitTestable(), findsOneWidget);
  });
}
