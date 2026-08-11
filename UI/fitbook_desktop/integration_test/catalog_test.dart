import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

Future<String> createTraining(WidgetTester tester, String naziv) async {
  await goToScreen(tester, 'Treninzi');
  await waitFor(tester, find.text('Dodaj trening'));

  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Dodaj trening'));
  await waitFor(tester, find.text('Dodaj novi trening'));

  await fillDialogField(tester, 0, naziv);
  await fillDialogField(tester, 1, 'Opis testnog treninga kreiranog iz UI testa');
  await selectDropdownOption(tester, dialogDropdowns().at(0));
  await selectDropdownOption(tester, dialogDropdowns().at(1));
  await fillDialogField(tester, 2, '45');
  await fillDialogField(tester, 3, '12');
  await saveDialogExpectingMessage(tester, 'uspješno');
  return naziv;
}

Future<void> deleteTraining(WidgetTester tester, String naziv) async {
  await goToScreen(tester, 'Treninzi');
  await waitFor(tester, find.text('Dodaj trening'));
  await searchFor(tester, naziv);
  await waitFor(tester, find.text(naziv));
  await openRowAction(tester, 'Obriši');
  await confirmDelete(tester);
  await searchFor(tester, naziv);
  await waitFor(tester, find.textContaining('Nema'));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CRUD kroz UI: Treninzi', (tester) async {
    await launchApp(tester, freshSession: true);

    final naziv = 'UI Trening ${uniqueSuffix()}';
    await createTraining(tester, naziv);

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));

    // UPDATE
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena treninga'));
    await fillDialogField(tester, 3, '20');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text('20'));

    // DETALJI (pregled)
    await openRowAction(tester, 'Pregled');
    await settle(tester);
    expect(find.textContaining(naziv), findsWidgets);
    final close = find.byTooltip('Zatvori');
    if (close.evaluate().isNotEmpty) {
      await tapAndSettle(tester, close);
    }

    await deleteTraining(tester, naziv);
  });

  testWidgets('validacija treninga traži kategoriju i nivo težine', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Treninzi');
    await waitFor(tester, find.text('Dodaj trening'));

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj trening'),
    );
    await waitFor(tester, find.text('Dodaj novi trening'));
    await saveDialog(tester);

    expect(find.text('Kategorija je obavezna.'), findsOneWidget);
    expect(find.text('Nivo težine je obavezan.'), findsOneWidget);
    expect(find.text('Dodaj novi trening'), findsOneWidget);

    await cancelDialog(tester);
    await waitForGone(tester, find.text('Dodaj novi trening'));
  });

  testWidgets('CRUD kroz UI: Oprema treninga', (tester) async {
    await launchApp(tester);

    // vlastiti trening da veza sigurno ne postoji od ranije
    final naziv = 'UI TrEq Trening ${uniqueSuffix()}';
    await createTraining(tester, naziv);

    await goToScreen(tester, 'Oprema treninga');
    await waitFor(tester, find.text('Dodaj opremu treningu'));

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj opremu treningu'),
    );
    await waitFor(tester, find.text('Dodaj opremu treningu'));

    await selectDropdownOption(
      tester,
      dialogDropdowns().at(0),
      optionText: naziv,
    );
    await selectDropdownOption(tester, dialogDropdowns().at(1));
    await fillDialogField(tester, 0, 'Napomena iz UI testa');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining(naziv));

    // UPDATE
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena opreme treninga'));
    await fillDialogField(tester, 0, 'Izmijenjena napomena');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Izmijenjena napomena'));

    // DELETE veze pa treninga
    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await settle(tester);

    await deleteTraining(tester, naziv);
  });

  testWidgets('CRUD kroz UI: Paketi članarina', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Paketi članarina');
    await waitFor(tester, find.text('Novi paket'));

    final naziv = 'UI Paket ${uniqueSuffix()}';

    await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Novi paket'));
    await waitFor(tester, find.text('Dodaj novi paket članarine'));

    await fillDialogField(tester, 0, naziv);
    await fillDialogField(tester, 1, '30');
    await fillDialogField(tester, 2, '49.99');
    await fillDialogField(tester, 3, '5.00');
    await fillDialogField(tester, 4, 'Neograničen pristup svim treninzima');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena paketa članarine'));
    await fillDialogField(tester, 2, '89.99');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('89'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('Novosti: slika je obavezna pri kreiranju', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Novosti');
    await waitFor(tester, find.text('Dodaj novost'));

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj novost'),
    );
    await waitFor(tester, find.text('Dodaj novost').last);

    await fillDialogField(tester, 0, 'UI Novost bez slike');
    await fillDialogField(tester, 1, 'Sadržaj novosti bez priložene slike.');
    await saveDialog(tester);

    expect(
      find.text('Slika novosti je obavezna.'),
      findsOneWidget,
      reason: 'kreiranje novosti bez slike mora biti spriječeno',
    );

    await cancelDialog(tester);
    await settle(tester);
  });

  testWidgets('Novosti: izmjena postojeće novosti i povratak na staro', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Novosti');
    await waitFor(tester, find.text('Lista novosti'));

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena novosti'));

    final original =
        (tester.widget(dialogFields().at(0)) as TextFormField)
            .controller
            ?.text ??
        '';
    expect(
      original.isNotEmpty,
      isTrue,
      reason: 'forma za izmjenu mora biti popunjena postojećim podacima',
    );

    final izmijenjen = '$original (UI test)';
    await fillDialogField(tester, 0, izmijenjen);
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, izmijenjen);
    await waitFor(tester, find.text(izmijenjen));

    // vraćanje na originalni naslov
    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena novosti'));
    await fillDialogField(tester, 0, original);
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, original);
    await waitFor(tester, find.text(original));
  });
}
