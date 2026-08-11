import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CRUD kroz UI: Korisnici', (tester) async {
    await launchApp(tester, freshSession: true);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));

    final sfx = uniqueSuffix();
    final username = 'uikorisnik$sfx';

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj korisnika'),
    );
    await waitFor(tester, find.text('Dodaj novog korisnika'));

    await fillDialogField(tester, 0, 'Testni');
    await fillDialogField(tester, 1, 'Korisnik$sfx');
    await fillDialogField(tester, 2, 'ui$sfx@fitbook.test');
    await fillDialogField(tester, 3, '+38761123456');
    await fillDialogField(tester, 4, username);
    await selectDropdownOption(
      tester,
      dialogDropdowns().at(0),
      optionText: 'Korisnik',
    );
    await fillDialogField(tester, 5, 'TestnaLozinka1');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, username);
    await waitFor(tester, find.text(username));

    // UPDATE
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena korisnika'));
    await fillDialogField(tester, 0, 'Izmijenjeni');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, username);
    await waitFor(tester, find.textContaining('Izmijenjeni'));

    // DELETE
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, username);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('validacija korisnika: email, telefon i lozinka', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj korisnika'),
    );
    await waitFor(tester, find.text('Dodaj novog korisnika'));

    await fillDialogField(tester, 2, 'nijeemail');
    await fillDialogField(tester, 5, '123');
    await saveDialog(tester);

    expect(find.text('Ime je obavezno polje.'), findsOneWidget);
    expect(find.textContaining('Email'), findsWidgets);
    expect(
      find.text('Lozinka mora imati najmanje 8 karaktera.'),
      findsOneWidget,
    );
    expect(find.text('Dodaj novog korisnika'), findsOneWidget);

    await cancelDialog(tester);
    await settle(tester);
  });

  testWidgets('CRUD kroz UI: Treneri', (tester) async {
    await launchApp(tester);

    final sfx = uniqueSuffix();
    final username = 'uitrener$sfx';
    final prezime = 'Trener$sfx';

    // trenerski nalog je preduslov za kreiranje trenera
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj korisnika'),
    );
    await waitFor(tester, find.text('Dodaj novog korisnika'));
    await fillDialogField(tester, 0, 'Testni');
    await fillDialogField(tester, 1, prezime);
    await fillDialogField(tester, 2, 'uit$sfx@fitbook.test');
    await fillDialogField(tester, 3, '+38761223344');
    await fillDialogField(tester, 4, username);
    await selectDropdownOption(
      tester,
      dialogDropdowns().at(0),
      optionText: 'Trener',
    );
    await fillDialogField(tester, 5, 'TestnaLozinka1');
    await saveDialogExpectingMessage(tester, 'uspješno');

    // CREATE trenera
    await goToScreen(tester, 'Treneri');
    await waitFor(tester, find.text('Dodaj trenera'));
    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj trenera'),
    );
    await waitFor(tester, find.text('Dodaj novog trenera'));

    await fillDialogField(tester, 0, 'Testni');
    await fillDialogField(tester, 1, prezime);
    await selectDropdownOption(tester, dialogDropdowns().at(0));
    await selectDropdownOption(
      tester,
      dialogDropdowns().at(1),
      optionText: 'Testni $prezime ($username)',
    );
    await fillDialogField(tester, 2, 'Biografija kreirana iz UI testa.');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, prezime);
    await waitFor(tester, find.textContaining(prezime));

    // UPDATE
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena trenera'));
    await fillDialogField(tester, 0, 'Izmijenjeni');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, prezime);
    await waitFor(tester, find.textContaining('Izmijenjeni'));

    // DELETE trenera pa naloga
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, prezime);
    await waitFor(tester, find.textContaining('Nema'));

    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.text('Dodaj korisnika'));
    await searchFor(tester, username);
    await waitFor(tester, find.text(username));
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await settle(tester);
  });

  testWidgets('CRUD kroz UI: Termini treninga', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Termini');
    await waitFor(tester, find.text('Dodaj termin'));

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj termin'));
    await waitFor(tester, find.text('Dodaj novi termin'));

    final trening = await selectDropdownOption(tester, dialogDropdowns().at(0));
    final treneri = <String>[];
    await selectDropdownOption(
      tester,
      dialogDropdowns().at(1),
      optionsOut: treneri,
    );
    await selectDropdownOption(tester, dialogDropdowns().at(2));
    await fillDialogField(tester, 0, '10');

    // Rani jutarnji termin istog dana: seed nikad ne zakazuje prije 07:00, pa
    // server ne može odbiti unos zbog preklapanja sa zauzetim trenerom ili
    // salom, bez obzira koje opcije padajuće liste ponude prve.
    await pickDateTime(tester, dialogFields().at(1), day: 25, hour: 5, minute: 0);
    await pickDateTime(tester, dialogFields().at(2), day: 25, hour: 6, minute: 0);

    expect(
      treneri,
      isNotEmpty,
      reason: 'padajuća lista mora ponuditi bar jednog trenera',
    );
    await saveDialogExpectingMessage(tester, 'uspješno');
    expect(
      find.textContaining('nije dostupan'),
      findsNothing,
      reason:
          'lista trenera smije nuditi samo dostupne trenere, '
          'inače server odbija svaki tako kreiran termin',
    );

    await searchFor(tester, trening);
    await waitFor(tester, find.textContaining(trening));

    // UPDATE broja učesnika
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena termina'));
    await fillDialogField(tester, 0, '8');
    await saveDialogExpectingMessage(tester, 'uspješno');
    await settle(tester);

    // OTKAZIVANJE termina
    await searchFor(tester, trening);
    final cancelAction = find.byTooltip('Otkaži termin');
    if (cancelAction.evaluate().isNotEmpty) {
      await tapAndSettle(tester, cancelAction.first);
      await settle(tester);
      final potvrdi = find.widgetWithText(FilledButton, 'Otkaži termin');
      if (potvrdi.evaluate().isNotEmpty) {
        await tapAndSettle(tester, potvrdi);
        await settle(tester);
      }
    }

    // DELETE
    await searchFor(tester, trening);
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await settle(tester);
  });

  testWidgets('validacija termina: kraj mora biti nakon početka', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Termini');
    await waitFor(tester, find.text('Dodaj termin'));

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj termin'));
    await waitFor(tester, find.text('Dodaj novi termin'));

    await selectDropdownOption(tester, dialogDropdowns().at(0));
    await selectDropdownOption(tester, dialogDropdowns().at(1));
    await selectDropdownOption(tester, dialogDropdowns().at(2));
    await fillDialogField(tester, 0, '5');

    // kraj namjerno raniji od početka (dan ranije), neovisno o vremenu
    await pickDateTime(tester, dialogFields().at(1), day: 25);
    await pickDateTime(tester, dialogFields().at(2), day: 24);

    await saveDialog(tester);
    expect(
      find.text('Kraj termina mora biti nakon početka.'),
      findsOneWidget,
      reason: 'forma mora spriječiti termin koji završava prije početka',
    );

    await cancelDialog(tester);
    await settle(tester);
  });
}
