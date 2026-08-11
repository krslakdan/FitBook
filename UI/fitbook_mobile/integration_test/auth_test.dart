import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('prijava vodi na početni ekran', (tester) async {
    await launchApp(tester);
    expect(find.text('Početna'), findsWidgets);
    expect(find.text('Treninzi'), findsWidgets);
    expect(find.text('Rezervacije'), findsWidgets);
    expect(find.text('Članarina'), findsWidgets);
    expect(find.text('Profil'), findsWidgets);
  });

  testWidgets('prijava sa pogrešnom lozinkom prikazuje grešku', (tester) async {
    await launchApp(tester, signIn: false);
    await login(tester, username: mobileUsername, password: 'pogresnalozinka');

    await waitFor(
      tester,
      find.textContaining('Neispravni podaci'),
      reason: 'poruka o neispravnim kredencijalima',
    );
    expect(find.text('Prijavi se'), findsWidgets);
  });

  testWidgets('prijava traži obavezna polja', (tester) async {
    await launchApp(tester, signIn: false);
    await waitFor(tester, find.text('Prijavi se'));

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Prijavi se'));
    expect(find.text('Korisničko ime je obavezno.'), findsOneWidget);
    expect(find.text('Lozinka je obavezna.'), findsOneWidget);
  });

  testWidgets('registracija validira unos', (tester) async {
    await launchApp(tester, signIn: false);
    await waitFor(tester, find.text('Registrujte se'));
    await tapAndSettle(tester, find.text('Registrujte se'));
    await waitFor(tester, find.text('Kreirajte nalog'));

    // prazna forma
    final submit = find.widgetWithText(FilledButton, 'Registruj se');
    if (submit.evaluate().isEmpty) {
      await scrollTo(tester, find.textContaining('Registr'));
    }
    await tapAndSettle(tester, find.byType(FilledButton).last);

    expect(find.text('Ime je obavezno.'), findsOneWidget);
    expect(find.text('Prezime je obavezno.'), findsOneWidget);
    expect(find.text('Email adresa je obavezna.'), findsOneWidget);

    // neispravan email i prekratka lozinka
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test');
    await tester.enterText(fields.at(1), 'Korisnik');
    await tester.enterText(fields.at(2), 'nijeemail');
    await settle(tester);
    expect(find.text('Email adresa nije u ispravnom formatu.'), findsOneWidget);

    // 0=ime, 1=prezime, 2=email, 3=telefon, 4=korisničko ime, 5=lozinka
    await tester.enterText(fields.at(5), 'kratka');
    await settle(tester);
    expect(
      find.text('Lozinka mora imati najmanje 8 karaktera.'),
      findsWidgets,
    );

    await tester.enterText(fields.at(5), 'DovoljnoDuga1');
    await tester.enterText(fields.at(6), 'DrugaLozinka1');
    await settle(tester);
    expect(find.text('Lozinke se ne podudaraju.'), findsWidgets);

    await goBack(tester);
    await waitFor(tester, find.text('Dobrodošli nazad'));
  });

  testWidgets('zaboravljena lozinka otvara svoj ekran', (tester) async {
    await launchApp(tester, signIn: false);
    await waitFor(tester, find.text('Zaboravili ste lozinku?'));
    await tapAndSettle(tester, find.text('Zaboravili ste lozinku?'));
    await settle(tester);

    expect(
      find.byType(TextFormField),
      findsWidgets,
      reason: 'ekran za oporavak lozinke mora imati polje za unos',
    );
    await goBack(tester);
    await waitFor(tester, find.text('Dobrodošli nazad'));
  });

  testWidgets('odjava vraća na ekran za prijavu', (tester) async {
    await launchApp(tester);
    await logout(tester);
    expect(find.text('Dobrodošli nazad'), findsWidgets);
  });

  testWidgets('trener se prijavljuje u svoju navigaciju', (tester) async {
    await launchApp(tester, username: trainerUsername);
    expect(find.text('Danas'), findsWidgets);
    expect(find.text('Termini'), findsWidgets);
    expect(find.text('Notifikacije'), findsWidgets);
    expect(
      find.text('Članarina'),
      findsNothing,
      reason: 'trener ne smije vidjeti korisničku karticu članarine',
    );
  });
}
