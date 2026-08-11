import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fitbook_desktop/widgets/crud/form_dialog.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Dashboard prikazuje pokazatelje i liste', (tester) async {
    await launchApp(tester, freshSession: true);
    await waitFor(tester, find.textContaining('UKUPNO KORISNIKA'));

    for (final kpi in const [
      'UKUPNO KORISNIKA',
      'UKUPNO TRENERA',
      'UKUPNO TRENINGA',
      'AKTIVNE REZERVACIJE',
      'AKTIVNE ČLANARINE',
      'PRIHOD (OVAJ MJESEC)',
    ]) {
      expect(
        find.textContaining(kpi),
        findsWidgets,
        reason: 'dashboard mora prikazati karticu "$kpi"',
      );
    }
  });

  testWidgets('Rezervacije: filter po statusu i dijalog detalja', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Rezervacije');
    await waitFor(tester, find.text('Lista rezervacija'));

    // filter po statusu
    await selectDropdownOption(
      tester,
      dropdowns().at(0),
      optionText: 'Otkazana',
    );
    await settle(tester);
    expect(
      find.text('Potvrđena'),
      findsNothing,
      reason: 'filter "Otkazana" ne smije prikazivati potvrđene rezervacije',
    );

    await tapAndSettle(
      tester,
      find.widgetWithText(OutlinedButton, 'Očisti filtere'),
    );
    await waitFor(tester, find.text('Lista rezervacija'));

    // dijalog detalja mora imati podatke o rezervaciji
    await openRowAction(tester, 'Pregled');
    await waitFor(tester, find.text('Detalji rezervacije'));
    for (final polje in const [
      'Trening',
      'Termin početak',
      'Termin kraj',
      'Rezervisano',
    ]) {
      expect(
        find.text(polje),
        findsOneWidget,
        reason: 'detalji rezervacije moraju prikazati polje "$polje"',
      );
    }

    final close = find.byTooltip('Zatvori');
    if (close.evaluate().isNotEmpty) await tapAndSettle(tester, close);
    await settle(tester);
  });

  testWidgets('Rezervacije: detalji prikazuju historiju promjena statusa', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Rezervacije');
    await waitFor(tester, find.text('Lista rezervacija'));

    // otkazane rezervacije sigurno imaju bar jednu promjenu statusa iza sebe
    await selectDropdownOption(
      tester,
      dropdowns().at(0),
      optionText: 'Otkazana',
    );
    await settle(tester);

    if (find.byTooltip('Pregled').evaluate().isEmpty) {
      markTestSkipped('Nema otkazanih rezervacija u sistemu.');
      return;
    }

    await openRowAction(tester, 'Pregled');
    await waitFor(tester, find.text('Detalji rezervacije'));
    await waitFor(
      tester,
      find.text('Historija statusa'),
      reason: 'sekcija sa historijom statusa',
    );

    // sekcija se puni zasebnim pozivom, pa se čeka da učitavanje završi
    await waitForGone(
      tester,
      find.descendant(
        of: find.byType(FormDialogShell),
        matching: find.byType(CircularProgressIndicator),
      ),
      reason: 'učitavanje historije statusa',
    );

    expect(
      find.textContaining('Nema evidentiranih promjena'),
      findsNothing,
      reason:
          'otkazana rezervacija mora imati zapisanu promjenu statusa '
          '(audit trail je obavezan)',
    );

    final prijelaz = find.textContaining('→');
    expect(
      prijelaz,
      findsWidgets,
      reason: 'historija mora prikazati prijelaz "stari status → novi status"',
    );
    expect(
      find.textContaining('Otkazana'),
      findsWidgets,
      reason: 'zadnji prijelaz mora završiti u statusu "Otkazana"',
    );

    // svaki zapis mora imati vrijeme i osobu koja je promjenu napravila
    final potpis = find.textContaining(' — ');
    expect(
      potpis,
      findsWidgets,
      reason:
          'uz svaku promjenu statusa mora stajati vrijeme i ko ju je napravio',
    );

    final close = find.byTooltip('Zatvori');
    if (close.evaluate().isNotEmpty) await tapAndSettle(tester, close);
    await settle(tester);
  });

  testWidgets('Rezervacije: otkazivanje traži razlog', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Rezervacije');
    await waitFor(tester, find.text('Lista rezervacija'));

    final cancelAction = find.byTooltip('Otkaži rezervaciju');
    if (cancelAction.evaluate().isEmpty) {
      markTestSkipped(
        'Na prvoj stranici nema rezervacije u statusu koji se može otkazati.',
      );
      return;
    }

    await tapAndSettle(tester, cancelAction.first);
    await waitFor(tester, find.text('Otkazivanje rezervacije'));

    // snimanje bez razloga mora biti spriječeno
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Otkaži rezervaciju'),
    );
    expect(
      find.text('Otkazivanje rezervacije'),
      findsOneWidget,
      reason: 'dijalog mora ostati otvoren dok razlog nije unesen',
    );
    expect(find.textContaining('Razlog'), findsWidgets);

    await cancelDialog(tester);
    await settle(tester);
  });

  testWidgets('Rezervacije: potvrda mijenja status u tabeli', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Rezervacije');
    await waitFor(tester, find.text('Lista rezervacija'));

    await selectDropdownOption(
      tester,
      dropdowns().at(0),
      optionText: 'Na čekanju',
    );
    await settle(tester);

    final confirmAction = find.byTooltip('Potvrdi rezervaciju');
    if (confirmAction.evaluate().isEmpty) {
      markTestSkipped(
        'Nema rezervacije u statusu "Na čekanju" koju bi bilo moguće potvrditi.',
      );
      return;
    }

    await tapAndSettle(tester, confirmAction.first);
    await waitFor(tester, find.text('Potvrda rezervacije'));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Potvrdi'));

    await waitFor(
      tester,
      find.textContaining('potvrđena'),
      reason: 'poruka o uspješnoj potvrdi',
    );
  });

  testWidgets('Članarine: filter statusa i detalji sa uplatama', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Članarine');
    await waitFor(tester, find.text('Lista članarina'));

    // filter po statusu stvarno sužava tabelu
    await selectDropdownOption(tester, dropdowns().at(0), optionText: 'Istekla');
    await settle(tester);
    expect(
      find.text('Aktivna'),
      findsNothing,
      reason: 'filter "Istekla" ne smije prikazivati aktivne članarine',
    );

    await tapAndSettle(
      tester,
      find.widgetWithText(OutlinedButton, 'Očisti filtere'),
    );
    await waitFor(tester, find.text('Lista članarina'));

    await openRowAction(tester, 'Pregled');
    await waitFor(tester, find.text('Detalji članarine'));

    // detalji moraju sadržavati podatke o paketu, plaćanju i historiji statusa
    expect(find.text('Paket'), findsWidgets);
    expect(find.text('Cijena paketa'), findsWidgets);
    expect(
      find.textContaining('Pla').evaluate().isNotEmpty,
      isTrue,
      reason: 'dijalog mora prikazati stanje plaćanja članarine',
    );

    final close = find.byTooltip('Zatvori');
    if (close.evaluate().isNotEmpty) await tapAndSettle(tester, close);
    await settle(tester);
  });

  testWidgets('Historija obavijesti: pretraga i filteri', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Historija obavijesti');
    await settle(tester);

    await selectDropdownOption(
      tester,
      dropdowns().at(1),
      optionText: 'Nepročitano',
    );
    await settle(tester);

    await searchFor(tester, 'nepostojeca-obavijest-xyz');
    await waitFor(tester, find.textContaining('Nema'));

    await tapAndSettle(
      tester,
      find.widgetWithText(OutlinedButton, 'Očisti filtere'),
    );
    await settle(tester);
    expect(find.textContaining('Nema'), findsNothing);
  });

  testWidgets('Izvještaji: validacija perioda', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Izvještaji');
    await waitFor(tester, find.textContaining('Termini od'));

    expect(find.text('Izvještaj o rezervacijama'), findsWidgets);
    expect(
      find.text('Popularnost treninga'),
      findsWidgets,
      reason: 'izvještaj o popularnosti treninga mora biti ponuđen',
    );

    // preuzimanje bez odabranog perioda mora biti spriječeno prije
    // otvaranja sistemskog dijaloga za snimanje
    await tapAndSettle(tester, find.text('Preuzmi PDF').first);
    await waitFor(
      tester,
      find.text('Odaberite početni i krajnji datum termina.'),
      reason: 'poruka o obaveznom periodu',
    );

    // obrnut period: kraj prije početka
    await pickDate(tester, find.text('Odaberite datum').first, 25);
    await pickDate(tester, find.text('Odaberite datum').first, 24);
    await tapAndSettle(tester, find.text('Preuzmi PDF').first);
    await waitFor(
      tester,
      find.text('Krajnji datum termina ne može biti prije početnog datuma.'),
      reason: 'poruka o obrnutom periodu',
    );
  });

  testWidgets('Odjava vraća na ekran za prijavu', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Dashboard');
    await settle(tester);

    await tapAndSettle(tester, find.text('Odjava').first);
    await waitFor(tester, find.text('Da li ste sigurni da se želite odjaviti?'));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Odjavi se'));

    await waitFor(
      tester,
      find.widgetWithText(FilledButton, 'Prijavi se'),
      reason: 'nakon odjave mora se prikazati ekran za prijavu',
    );
  });

  testWidgets('prijava sa pogrešnom lozinkom prikazuje grešku', (tester) async {
    await launchApp(tester, freshSession: true);

    // launchApp se prijavi, pa se prvo odjavimo
    await tapAndSettle(tester, find.text('Odjava').first);
    await waitFor(tester, find.text('Da li ste sigurni da se želite odjaviti?'));
    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Odjavi se'));
    await waitFor(tester, find.widgetWithText(FilledButton, 'Prijavi se'));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'desktop');
    await tester.enterText(fields.at(1), 'pogresnalozinka');
    await settle(tester);
    await tester.tap(
      find.widgetWithText(FilledButton, 'Prijavi se'),
      warnIfMissed: false,
    );

    await waitFor(
      tester,
      find.textContaining('Neispravni podaci'),
      reason: 'poruka o neispravnim kredencijalima',
    );
    expect(
      find.widgetWithText(FilledButton, 'Prijavi se'),
      findsOneWidget,
      reason: 'korisnik mora ostati na ekranu za prijavu',
    );
  });

  /// Desktop aplikacija je administratorska, pa nalozi ostalih uloga moraju
  /// biti odbijeni i sa ispravnom lozinkom.
  testWidgets('nalozi koji nisu administratori ne mogu u desktop aplikaciju', (
    tester,
  ) async {
    await launchApp(tester, freshSession: true);
    await _logout(tester);

    for (final username in const ['mobile', 'trainer']) {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), username);
      await tester.enterText(fields.at(1), 'test');
      await settle(tester);
      await tester.tap(
        find.widgetWithText(FilledButton, 'Prijavi se'),
        warnIfMissed: false,
      );

      await waitFor(
        tester,
        find.textContaining('samo administratorima'),
        reason:
            'nalog "$username" ima ispravnu lozinku, ali nije administrator '
            'pa mu pristup desktop aplikaciji mora biti odbijen',
      );
      expect(
        find.text('Dashboard'),
        findsNothing,
        reason: 'nalog "$username" ne smije doći do administratorskog ekrana',
      );
      expect(
        find.widgetWithText(FilledButton, 'Prijavi se'),
        findsOneWidget,
        reason: 'korisnik ostaje na ekranu za prijavu',
      );
      await settle(tester);
    }
  });
}

Future<void> _logout(WidgetTester tester) async {
  await tapAndSettle(tester, find.text('Odjava').first);
  await waitFor(tester, find.text('Da li ste sigurni da se želite odjaviti?'));
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Odjavi se'));
  await waitFor(tester, find.widgetWithText(FilledButton, 'Prijavi se'));
  await settle(tester);
}
