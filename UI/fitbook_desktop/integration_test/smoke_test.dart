import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prijava vodi na dashboard', (tester) async {
    await launchApp(tester, freshSession: true);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.textContaining('UKUPNO KORISNIKA'), findsWidgets);
  });

  testWidgets('svi ekrani se otvaraju iz bočne navigacije', (tester) async {
    await launchApp(tester);

    const screens = <String, String>{
      'Korisnici': 'Dodaj korisnika',
      'Treneri': 'Dodaj trenera',
      'Treninzi': 'Dodaj trening',
      'Termini': 'Dodaj termin',
      'Rezervacije': 'Lista rezervacija',
      'Članarine': 'Pretraga',
      'Paketi članarina': 'Pretraga',
      'Kategorije': 'Dodaj kategoriju',
      'Nivoi težine': 'Dodaj nivo težine',
      'Sale': 'Dodaj salu',
      'Oprema': 'Dodaj opremu',
      'Oprema treninga': 'Dodaj opremu treningu',
      'Specijalizacije': 'Dodaj specijalizaciju',
      'Novosti': 'Dodaj novost',
      'Historija obavijesti': 'Pretraga',
      'Izvještaji': 'Izvještaji',
    };

    for (final entry in screens.entries) {
      await goToScreen(tester, entry.key);
      await waitFor(
        tester,
        find.textContaining(entry.value),
        reason: 'ekran "${entry.key}" nije prikazao "${entry.value}"',
      );
    }
  });

  testWidgets('CRUD kroz UI: Sale', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Sale');
    await waitFor(tester, find.text('Dodaj salu'));

    final naziv = 'UI Sala ${uniqueSuffix()}';

    // CREATE
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj salu'));
    await waitFor(tester, find.text('Dodaj novu salu'));
    await fillDialogField(tester, 0, naziv);
    await fillDialogField(tester, 1, '25');
    await fillDialogField(tester, 2, 'Prizemlje, lijevo krilo');
    await saveDialogExpectingMessage(tester, 'uspješno dodana');
    await waitForGone(tester, find.text('Dodaj novu salu'));

    // READ - zapis se vidi u tabeli nakon pretrage
    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));
    expect(find.text('25'), findsWidgets);

    // UPDATE
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena sale'));
    await fillDialogField(tester, 1, '40');
    await saveDialogExpectingMessage(tester, 'uspješno izmijenjena');
    await waitForGone(tester, find.text('Izmjena sale'));

    await searchFor(tester, naziv);
    await waitFor(tester, find.text('40'));

    // DELETE
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await settle(tester);

    await searchFor(tester, naziv);
    await waitFor(
      tester,
      find.textContaining('Nema sala'),
      reason: 'sala je trebala nestati iz tabele nakon brisanja',
    );
  });

  testWidgets('validacija forme sprječava snimanje praznog zapisa', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Sale');
    await waitFor(tester, find.text('Dodaj salu'));

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj salu'));
    await waitFor(tester, find.text('Dodaj novu salu'));

    // snimanje bez ijednog unesenog polja
    await saveDialog(tester);

    expect(find.text('Naziv je obavezno polje.'), findsOneWidget);
    expect(find.text('Kapacitet je obavezno polje.'), findsOneWidget);
    expect(
      find.text('Dodaj novu salu'),
      findsOneWidget,
      reason: 'dijalog mora ostati otvoren kada validacija ne prođe',
    );

    // neispravan kapacitet
    await fillDialogField(tester, 0, 'A');
    await fillDialogField(tester, 1, '-3');
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Naziv mora imati najmanje 2 karaktera.'), findsOneWidget);
    expect(
      find.text('Kapacitet mora biti pozitivan cijeli broj.'),
      findsOneWidget,
    );

    await cancelDialog(tester);
    await waitForGone(tester, find.text('Dodaj novu salu'));
  });
}
