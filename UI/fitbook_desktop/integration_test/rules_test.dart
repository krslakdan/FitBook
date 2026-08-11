import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fitbook_desktop/widgets/crud/form_dialog.dart';

import 'helpers.dart';

/// Pravila iz uputa koja se ne vide kroz obični CRUD tok:
/// izmjena lozinke, poruke servera u formi, referencijalni integritet,
/// redoslijed novih zapisa i kontrola broja zapisa po stranici.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('izmjena korisnika ne traži lozinku dok se ne zatraži', (
    tester,
  ) async {
    await launchApp(tester, freshSession: true);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));

    await searchFor(tester, 'mobile');
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena korisnika'));

    // ime, prezime, email, telefon, korisničko ime - bez polja za lozinku
    expect(
      dialogFields().evaluate().length,
      5,
      reason:
          'forma za izmjenu ne smije tražiti lozinku dok korisnik to ne zatraži',
    );
    expect(find.text('Izmijeni lozinku'), findsOneWidget);

    // checkbox otvara polje za novu lozinku i potvrdu
    await tapAndSettle(tester, find.text('Izmijeni lozinku'));
    expect(
      dialogFields().evaluate().length,
      7,
      reason: '"Izmijeni lozinku" mora otvoriti dva polja za lozinku',
    );
    // labele su Text.rich zbog oznake obaveznog polja, pa im treba findRichText
    expect(
      find.textContaining('Nova lozinka', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining('Potvrda nove lozinke', findRichText: true),
      findsWidgets,
    );
    expect(
      find.textContaining('Trenutna lozinka', findRichText: true),
      findsNothing,
      reason: 'administrator ne unosi staru lozinku korisnika',
    );

    // nepodudarne lozinke se moraju uhvatiti prije slanja
    await fillDialogField(tester, 5, 'NovaLozinka1');
    await fillDialogField(tester, 6, 'DrugaLozinka1');
    await saveDialog(tester);
    expect(find.text('Lozinke se ne podudaraju.'), findsOneWidget);
    expect(
      find.text('Izmjena korisnika'),
      findsOneWidget,
      reason: 'dijalog mora ostati otvoren dok validacija ne prođe',
    );

    // gašenje checkboxa vraća formu u stanje bez lozinke
    await tapAndSettle(tester, find.text('Izmijeni lozinku'));
    expect(dialogFields().evaluate().length, 5);

    await cancelDialog(tester);
    await waitForGone(tester, find.text('Izmjena korisnika'));
  });

  testWidgets('duplo korisničko ime prikazuje poruku servera u formi', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));

    final sfx = uniqueSuffix();
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj korisnika'),
    );
    await waitFor(tester, find.text('Dodaj novog korisnika'));

    await fillDialogField(tester, 0, 'Duplikat');
    await fillDialogField(tester, 1, 'Provjera');
    await fillDialogField(tester, 2, 'dup$sfx@fitbook.test');
    await fillDialogField(tester, 3, '+38761998877');
    // korisničko ime koje sigurno postoji u seed podacima
    await fillDialogField(tester, 4, 'desktop');
    await selectDropdownOption(
      tester,
      dialogDropdowns().at(0),
      optionText: 'Korisnik',
    );
    await fillDialogField(tester, 5, 'TestnaLozinka1');
    await saveDialog(tester);

    await waitFor(
      tester,
      find.descendant(
        of: find.byType(FormDialogShell),
        matching: find.textContaining('već postoji'),
      ),
      reason:
          'poruka servera o zauzetom korisničkom imenu mora biti prikazana '
          'unutar forme, a ne sakrivena generičkom porukom',
    );
    expect(
      find.text('Dodaj novog korisnika'),
      findsOneWidget,
      reason: 'forma ostaje otvorena sa unesenim podacima',
    );

    await cancelDialog(tester);
    await waitForGone(tester, find.text('Dodaj novog korisnika'));
  });

  testWidgets('brisanje kategorije u upotrebi objašnjava razlog', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Kategorije');
    await waitFor(tester, find.text('Dodaj kategoriju'));

    // "Kardio" je seed kategorija na koju su vezani treninzi
    await searchFor(tester, 'Kardio');
    await waitFor(tester, find.text('Kardio'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester, expectMessage: 'ne može biti obrisana');

    expect(
      find.textContaining('treninzi koji je koriste'),
      findsWidgets,
      reason: 'poruka mora navesti koji entiteti drže referencu',
    );

    // zapis mora ostati u tabeli
    await searchFor(tester, 'Kardio');
    await waitFor(tester, find.text('Kardio'));
  });

  testWidgets('novi zapis se prikazuje na vrhu liste bez ručnog osvježavanja', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Sale');
    await waitFor(tester, find.text('Dodaj salu'));

    final prva = 'UI Redoslijed A ${uniqueSuffix()}';
    await _addHall(tester, prva, '11');

    final druga = 'UI Redoslijed B ${uniqueSuffix()}';
    await _addHall(tester, druga, '12');

    // obje sale moraju biti vidljive na prvoj stranici odmah nakon snimanja
    await waitFor(
      tester,
      find.text(druga),
      reason: 'novi zapis mora biti u tabeli bez ručnog osvježavanja',
    );
    expect(find.text(prva), findsOneWidget);

    expect(
      tester.getTopLeft(find.text(druga)).dy,
      lessThan(tester.getTopLeft(find.text(prva)).dy),
      reason: 'najnoviji zapis mora biti prikazan iznad starijeg',
    );

    await _deleteHall(tester, druga);
    await _deleteHall(tester, prva);
  });

  testWidgets('onemogućene akcije rezervacije objašnjavaju razlog', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Rezervacije');
    await waitFor(tester, find.text('Lista rezervacija'));

    await selectDropdownOption(
      tester,
      dropdowns().at(0),
      optionText: 'Završena',
    );
    await settle(tester);

    if (find.byTooltip('Pregled').evaluate().isEmpty) {
      markTestSkipped('Nema završenih rezervacija u sistemu.');
      return;
    }

    for (final reason in const [
      'Završena rezervacija se ne može potvrditi.',
      'Rezervacija je već završena.',
      'Završena rezervacija se ne može otkazati.',
    ]) {
      expect(
        find.byTooltip(reason),
        findsWidgets,
        reason:
            'nedostupna akcija mora objasniti razlog, a ne samo reći da nije '
            'moguća ("$reason")',
      );
    }

    expect(
      find.byTooltip('Rezervacija se ne može potvrditi.'),
      findsNothing,
      reason: 'stara poruka bez razloga se više ne smije pojavljivati',
    );
  });

  testWidgets('promjena broja zapisa po stranici mijenja veličinu stranice', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.textContaining('Prikazano 1 do 10'));

    await tapAndSettle(tester, find.byType(DropdownButton<int>).first);
    await tapAndSettle(tester, find.text('5 po stranici').last);

    await waitFor(
      tester,
      find.textContaining('Prikazano 1 do 5'),
      reason: 'odabir "5 po stranici" mora suziti stranicu na 5 zapisa',
    );

    await tapAndSettle(tester, find.byIcon(Icons.arrow_forward));
    await waitFor(
      tester,
      find.textContaining('Prikazano 6 do 10'),
      reason: 'druga stranica pri veličini 5 počinje od 6. zapisa',
    );
  });
}

Future<void> _addHall(WidgetTester tester, String naziv, String kapacitet) async {
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj salu'));
  await waitFor(tester, find.text('Dodaj novu salu'));
  await fillDialogField(tester, 0, naziv);
  await fillDialogField(tester, 1, kapacitet);
  await saveDialogExpectingMessage(tester, 'uspješno dodana');
  await waitForGone(tester, find.text('Dodaj novu salu'));
}

Future<void> _deleteHall(WidgetTester tester, String naziv) async {
  await searchFor(tester, naziv);
  await waitFor(tester, find.text(naziv));
  await openRowAction(tester, 'Obriši');
  await confirmDelete(tester);
  await settle(tester);
  await tapAndSettle(
    tester,
    find.widgetWithText(OutlinedButton, 'Očisti filtere'),
  );
  await settle(tester);
}
