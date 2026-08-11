import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Početna prikazuje pokazatelje i status članarine', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Početna');
    await waitFor(tester, find.text('Sljedeći trening'));

    expect(
      find.text('Aktivne rezervacije'),
      findsWidgets,
      reason: 'početni ekran mora prikazati broj aktivnih rezervacija',
    );
    expect(
      find.textContaining('lanarina'),
      findsWidgets,
      reason: 'početni ekran mora prikazati status članarine',
    );
    expect(
      find.textContaining('Zdravo'),
      findsWidgets,
      reason: 'pozdrav sa imenom prijavljenog korisnika',
    );
  });

  testWidgets('Treninzi: lista, pretraga i detalji', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Treninzi');
    await waitFor(tester, find.text('Pregled dostupnih treninga'));

    // pretraga bez rezultata
    await tester.enterText(find.byType(TextField).first, 'nepostojeci-xyz');
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);
    await waitFor(tester, find.textContaining('Nema treninga'));

    // vrati pretragu
    await tester.enterText(find.byType(TextField).first, '');
    await tester.pump(const Duration(milliseconds: 800));
    await settle(tester);
    await waitForGone(tester, find.textContaining('Nema treninga'));

    // otvori prvi trening
    await tapAndSettle(tester, itemsOfType('_TrainingCard').first);
    await waitFor(tester, find.text('Trajanje'), reason: 'detalji treninga');
    expect(find.text('Max učesnika'), findsWidgets);

    await goBack(tester);
    await waitFor(tester, find.text('Pregled dostupnih treninga'));
  });

  testWidgets('Rezervacije: kartice aktivnih i prošlih', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Rezervacije');
    await waitFor(tester, find.text('Vaše rezervacije treninga'));

    expect(find.text('Aktivne'), findsWidgets);
    expect(find.text('Prošle'), findsWidgets);

    await tapAndSettle(tester, find.text('Prošle'));
    await settle(tester);
    await tapAndSettle(tester, find.text('Aktivne'));
    await settle(tester);
  });

  testWidgets('rezervisanje termina pa otkazivanje kroz UI', (tester) async {
    await launchApp(tester, username: memberUsername);

    // Dugme "Pogledaj termine" je onemogućeno za treninge bez zakazanih
    // termina, pa tražimo prvi trening koji ih stvarno ima.
    await goToTab(tester, 'Treninzi');
    await waitFor(tester, find.text('Pregled dostupnih treninga'));

    var reserved = false;
    final trainingCount = itemsOfType('_TrainingCard').evaluate().length;

    for (var i = 0; i < trainingCount && !reserved; i++) {
      await tapAndSettle(tester, itemsOfType('_TrainingCard').at(i));
      await waitFor(tester, find.text('Pogledaj termine'));

      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Pogledaj termine'),
      );
      if (button.onPressed == null) {
        await goBack(tester);
        await waitFor(tester, find.text('Pregled dostupnih treninga'));
        continue;
      }

      await tapAndSettle(tester, find.text('Pogledaj termine'));
      await waitFor(tester, find.text('Dostupni termini'));

      final termCount = itemsOfType('TermCard').evaluate().length;
      for (var t = 0; t < termCount && !reserved; t++) {
        await tapAndSettle(tester, itemsOfType('TermCard').at(t));
        await waitFor(tester, find.text('Detalji termina'));

        if (find.text('Rezerviši mjesto').evaluate().isNotEmpty) {
          await tapAndSettle(tester, find.text('Rezerviši mjesto'));
          await waitFor(tester, find.text('Potvrda rezervacije'));
          await tapAndSettle(tester, find.text('Rezerviši'));
          await waitFor(
            tester,
            find.textContaining('čeka potvrdu'),
            reason: 'poruka o kreiranoj rezervaciji',
          );
          reserved = true;
        } else {
          await goBack(tester);
          await waitFor(tester, find.text('Dostupni termini'));
        }
      }

      if (!reserved) {
        await goBack(tester);
        await settle(tester);
        await goBack(tester);
        await waitFor(tester, find.text('Pregled dostupnih treninga'));
      }
    }

    expect(
      reserved,
      isTrue,
      reason: 'nijedan termin nije bio dostupan za rezervaciju',
    );

    // rezervacija se pojavljuje među aktivnim
    await goToTab(tester, 'Rezervacije');
    await waitFor(tester, find.text('Vaše rezervacije treninga'));
    await settle(tester);
    expect(
      find.textContaining('Nema aktivnih rezervacija'),
      findsNothing,
      reason: 'nova rezervacija mora biti među aktivnim',
    );

    // otvori upravo kreiranu (još nepotvrđenu) rezervaciju
    final pendingCard = find.ancestor(
      of: find.text('Na čekanju'),
      matching: itemsOfType('_ReservationCard'),
    );
    await waitFor(
      tester,
      pendingCard,
      reason: 'kartica rezervacije u statusu "Na čekanju"',
    );
    await tapAndSettle(tester, pendingCard.first);
    await waitFor(tester, find.text('Otkaži rezervaciju'));

    // Dugme na ekranu i dugme u dijalogu imaju isti tekst, pa se potvrda
    // mora tražiti unutar samog dijaloga.
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Otkaži rezervaciju'),
    );
    await waitFor(tester, find.byType(AlertDialog), reason: 'dijalog potvrde');

    final dialogConfirm = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.widgetWithText(FilledButton, 'Otkaži rezervaciju'),
    );

    // razlog je obavezan
    await tapAndSettle(tester, dialogConfirm);
    expect(
      find.text('Razlog otkazivanja je obavezan.'),
      findsOneWidget,
      reason: 'otkazivanje bez razloga mora biti spriječeno',
    );

    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'Otkazano tokom automatiziranog UI testa',
    );
    await settle(tester);
    await tapAndSettle(tester, dialogConfirm);

    await waitFor(
      tester,
      find.textContaining('otkazana'),
      reason: 'poruka o otkazanoj rezervaciji',
    );
  });

  testWidgets('Članarina: paketi i historija', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Članarina');
    await waitFor(tester, find.text('Vaše članstvo i paketi'));

    await tapAndSettle(tester, find.byTooltip('Historija članarina'));
    await waitFor(tester, find.text('Sve Vaše članarine'));

    for (final tab in const ['Aktivne', 'Na čekanju', 'Istekle', 'Otkazane']) {
      await tapAndSettle(tester, find.text(tab));
      await settle(tester);
    }

    await goBack(tester);
    await waitFor(tester, find.text('Vaše članstvo i paketi'));
  });

  testWidgets('Profil: izmjena podataka i povratak na staro', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Uredi profil'));

    await tapAndSettle(tester, find.text('Uredi profil'));
    await waitFor(tester, find.byType(TextFormField));

    final original =
        (tester.widget(find.byType(TextFormField).first) as TextFormField)
            .controller
            ?.text ??
        '';
    expect(original.isNotEmpty, isTrue, reason: 'forma mora biti popunjena');

    // validacija praznog polja
    await tester.enterText(find.byType(TextFormField).first, '');
    await settle(tester);
    expect(find.text('Ime je obavezno.'), findsWidgets);

    // stvarna izmjena
    await tester.enterText(find.byType(TextFormField).first, '${original}ko');
    await settle(tester);
    await tapAndSettle(tester, find.byType(FilledButton).last);
    await waitFor(
      tester,
      find.textContaining('uspješno ažuriran'),
      reason: 'poruka o ažuriranom profilu',
    );

    // vrati originalno ime
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Uredi profil'));
    await tapAndSettle(tester, find.text('Uredi profil'));
    await waitFor(tester, find.byType(TextFormField));
    await tester.enterText(find.byType(TextFormField).first, original);
    await settle(tester);
    await tapAndSettle(tester, find.byType(FilledButton).last);
    await waitFor(tester, find.textContaining('uspješno ažuriran'));
  });

  testWidgets('Profil: promjena lozinke validira unos', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Promijeni lozinku'));
    await tapAndSettle(tester, find.text('Promijeni lozinku'));
    await waitFor(tester, find.byType(TextFormField));

    await tapAndSettle(tester, find.byType(FilledButton).last);
    expect(find.text('Trenutna lozinka je obavezna.'), findsWidgets);
    expect(find.text('Nova lozinka je obavezna.'), findsWidgets);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'test');
    await tester.enterText(fields.at(1), 'NovaLozinka1');
    await tester.enterText(fields.at(2), 'DrugaLozinka1');
    await settle(tester);
    expect(find.text('Lozinke se ne podudaraju.'), findsWidgets);

    await goBack(tester);
    await settle(tester);
  });

  testWidgets('Profil: notifikacije prikazuju listu ili prazno stanje', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Notifikacije'));
    await tapAndSettle(tester, find.text('Notifikacije'));
    await settle(tester);

    final tiles = itemsOfType('_NotificationTile');
    final empty = find.text('Nema notifikacija');
    expect(
      tiles.evaluate().isNotEmpty || empty.evaluate().isNotEmpty,
      isTrue,
      reason:
          'ekran mora prikazati ili notifikacije ili jasno prazno stanje, '
          'a ne beskonačni indikator učitavanja',
    );

    if (tiles.evaluate().isNotEmpty) {
      expect(
        find.byType(Divider).evaluate().isNotEmpty ||
            visibleTexts().isNotEmpty,
        isTrue,
      );
    }

    await goBack(tester);
    await settle(tester);
  });

  testWidgets('Profil: novosti se otvaraju', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Novosti'));
    await tapAndSettle(tester, find.text('Novosti'));
    await waitFor(tester, find.text('Najnovije objave'));

    if (itemsOfType('_NewsCard').evaluate().isNotEmpty) {
      await tapAndSettle(tester, itemsOfType('_NewsCard').first);
      await settle(tester);
      await goBack(tester);
      await settle(tester);
    }

    await goBack(tester);
    await settle(tester);
  });
}
