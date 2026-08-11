import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitbook_mobile/main.dart';

/// Demo nalog iz README-a; runtime seeder mu kreira svježu aktivnu članarinu.
const mobileUsername = 'mobile';

/// Seed nalog sa aktivnom članarinom i historijom rezervacija, pa ima i
/// preporuke. Koristi se za testove koji zavise od stvarnih podataka.
const memberUsername = 'amina';
const trainerUsername = 'trainer';

/// Seed nalog kojem je jedna rezervacija otkazana sa upisanim razlogom, pa se
/// na njemu provjerava kako aplikacija prikazuje završeno stanje rezervacije.
const cancelledReservationUsername = 'lejla';
const seedPassword = 'test';

String uniqueSuffix() =>
    DateTime.now().microsecondsSinceEpoch.remainder(100000000).toString();

Future<void> settle(WidgetTester tester, {int maxFrames = 120}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) return;
  }
}

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  throw TestFailure(
    'Isteklo vrijeme čekanja na: ${reason ?? finder.toString()}\n'
    'Vidljivo: ${visibleTexts().join(" | ")}',
  );
}

Future<void> waitForGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  throw TestFailure('Element nije nestao: ${reason ?? finder.toString()}');
}

List<String> visibleTexts({int limit = 60}) {
  final result = <String>[];
  for (final element in find.byType(Text).evaluate()) {
    final data = (element.widget as Text).data;
    if (data != null && data.trim().isNotEmpty) result.add(data.trim());
    if (result.length >= limit) break;
  }
  return result;
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder.first, warnIfMissed: false);
  await settle(tester);
}

/// Scrolls the nearest list until [finder] is on screen.
Future<void> scrollTo(
  WidgetTester tester,
  Finder finder, {
  double delta = 200,
}) async {
  if (finder.evaluate().isNotEmpty) return;
  final scrollable = find.byType(Scrollable);
  if (scrollable.evaluate().isEmpty) return;
  try {
    await tester.scrollUntilVisible(
      finder,
      delta,
      scrollable: scrollable.first,
      maxScrolls: 30,
    );
  } catch (_) {
    // ostavi provjeru pozivaocu
  }
  await settle(tester);
}

Future<void> logout(WidgetTester tester) async {
  await goToTab(tester, 'Profil');
  await scrollTo(tester, find.text('Odjava'));
  await tapAndSettle(tester, find.text('Odjava').last);
  await waitFor(tester, find.text('Odjavi se'));
  await tapAndSettle(tester, find.text('Odjavi se'));
  await waitFor(tester, find.text('Prijavi se'));
  // waitFor vraća čim se tekst pojavi, a to je na početku animacije prelaska
  // na ekran za prijavu; bez ovoga naredni tap pada na staru poziciju dugmeta.
  await settle(tester);
}

/// Ekran za prijavu je meta i nakon odjave, kada je još u animaciji, pa se
/// unos i tap ponavljaju dok prijava stvarno ne krene.
Future<void> login(
  WidgetTester tester, {
  String username = mobileUsername,
  String password = seedPassword,
  int attempts = 3,
}) async {
  await waitFor(tester, find.text('Prijavi se'), reason: 'ekran za prijavu');
  await settle(tester);

  final loginButton = find.widgetWithText(FilledButton, 'Prijavi se');

  for (var attempt = 1; attempt <= attempts; attempt++) {
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), username);
    await tester.enterText(fields.at(1), password);
    await settle(tester);

    await tapAndSettle(tester, loginButton);

    // prijava je krenula ako je forma nestala ili je server vratio poruku
    if (loginButton.evaluate().isEmpty ||
        find.textContaining('Neispravni podaci').evaluate().isNotEmpty ||
        find.textContaining('Nemate pravo').evaluate().isNotEmpty ||
        find.textContaining('nije aktivan').evaluate().isNotEmpty) {
      return;
    }

    if (attempt == attempts) {
      throw TestFailure(
        'Prijava korisnika "$username" nije pokrenuta nakon $attempts '
        'pokušaja. Vidljivo: ${visibleTexts().join(" | ")}',
      );
    }
    await tester.pump(const Duration(milliseconds: 400));
  }
}

Future<void> launchApp(
  WidgetTester tester, {
  String username = mobileUsername,
  bool freshSession = true,
  bool signIn = true,
}) async {
  if (freshSession) {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  await tester.pumpWidget(const FitBookMobileApp());
  await settle(tester);

  if (!signIn) return;

  // ako je sesija ostala od prethodnog testa, odjavi se prvo
  if (find.text('Prijavi se').evaluate().isEmpty) {
    await logout(tester);
  }

  await login(tester, username: username);
  // "Profil" je jedina kartica koju imaju i korisnička i trenerska navigacija
  await waitFor(
    tester,
    find.text('Profil'),
    reason: 'glavna navigacija nakon prijave korisnika "$username"',
  );
}

/// Pops pushed routes until the bottom navigation is reachable again.
Future<void> returnToRoot(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    if (itemsOfType('AppBottomNav').evaluate().isNotEmpty) return;
    await goBack(tester);
    await settle(tester);
  }
}

/// Bottom navigation labels: Početna, Treninzi, Rezervacije, Članarina, Profil
/// (trener: Danas, Termini, Notifikacije, Profil).
Future<void> goToTab(WidgetTester tester, String label) async {
  await returnToRoot(tester);
  await waitFor(tester, find.text(label), reason: 'kartica "$label"');
  await tapAndSettle(tester, find.text(label).last);
  await settle(tester);
}

/// List items are private widget classes (_TrainingCard, _ReservationCard, …)
/// that cannot be referenced by type from a test, so they are matched by
/// runtime type name.
Finder itemsOfType(String typeName) => find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == typeName,
);

Future<void> goBack(WidgetTester tester) async {
  final back = find.byTooltip('Back');
  if (back.evaluate().isNotEmpty) {
    await tapAndSettle(tester, back);
    return;
  }
  final arrow = find.byIcon(Icons.arrow_back);
  if (arrow.evaluate().isNotEmpty) {
    await tapAndSettle(tester, arrow);
    return;
  }
  final ios = find.byIcon(Icons.arrow_back_ios_new);
  if (ios.evaluate().isNotEmpty) {
    await tapAndSettle(tester, ios);
  }
}
