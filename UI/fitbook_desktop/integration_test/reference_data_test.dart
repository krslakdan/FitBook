import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CRUD kroz UI: Specijalizacije', (tester) async {
    await launchApp(tester, freshSession: true);
    await goToScreen(tester, 'Specijalizacije');
    await waitFor(tester, find.text('Dodaj specijalizaciju'));

    final naziv = 'UI Specijalizacija ${uniqueSuffix()}';

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj specijalizaciju'),
    );
    await waitFor(tester, find.textContaining('specijalizacij'));
    await fillDialogField(tester, 0, naziv);
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena specijalizacije'));
    await fillDialogField(tester, 0, '$naziv izmijenjeno');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, '$naziv izmijenjeno');
    await waitFor(tester, find.text('$naziv izmijenjeno'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('CRUD kroz UI: Oprema', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Oprema');
    await waitFor(tester, find.text('Dodaj opremu'));

    final naziv = 'UI Oprema ${uniqueSuffix()}';

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj opremu'),
    );
    await waitFor(tester, find.text('Dodaj novu opremu'));
    await fillDialogField(tester, 0, naziv);
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena opreme'));
    await fillDialogField(tester, 0, '$naziv v2');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, '$naziv v2');
    await waitFor(tester, find.text('$naziv v2'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('CRUD kroz UI: Nivoi težine', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Nivoi težine');
    await waitFor(tester, find.text('Dodaj nivo težine'));

    final naziv = 'UI Nivo ${uniqueSuffix()}';

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj nivo težine'),
    );
    await waitFor(tester, find.text('Dodaj novi nivo težine'));
    await fillDialogField(tester, 0, naziv);
    await fillDialogField(tester, 1, '77');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));
    expect(find.text('77'), findsWidgets);

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena nivoa težine'));
    await fillDialogField(tester, 1, '88');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text('88'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('CRUD kroz UI: Kategorije treninga', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Kategorije');
    await waitFor(tester, find.text('Dodaj kategoriju'));

    final naziv = 'UI Kategorija ${uniqueSuffix()}';

    await tapAndSettle(
      tester,
      find.widgetWithText(FilledButton, 'Dodaj kategoriju'),
    );
    await waitFor(tester, find.textContaining('kategorij'));
    await fillDialogField(tester, 0, naziv);
    await fillDialogField(tester, 1, 'Opis testne kategorije');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text(naziv));

    await openRowAction(tester, 'Izmijeni');
    await waitFor(tester, find.text('Izmjena kategorije treninga'));
    await fillDialogField(tester, 1, 'Izmijenjeni opis');
    await saveDialogExpectingMessage(tester, 'uspješno');

    await searchFor(tester, naziv);
    await waitFor(tester, find.text('Izmijenjeni opis'));

    await openRowAction(tester, 'Obriši');
    await confirmDelete(tester);
    await searchFor(tester, naziv);
    await waitFor(tester, find.textContaining('Nema'));
  });

  testWidgets('pretraga i filter statusa sužavaju tabelu', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Sale');
    await waitFor(tester, find.text('Dodaj salu'));

    // pretraga koja sigurno nema pogodaka
    await searchFor(tester, 'nepostojeci-zapis-xyz');
    await waitFor(tester, find.textContaining('Nema sala'));

    // čišćenje filtera vraća podatke
    await tapAndSettle(
      tester,
      find.widgetWithText(OutlinedButton, 'Očisti filtere'),
    );
    await waitFor(tester, find.text('Lista sala'));
    expect(
      find.textContaining('Nema sala'),
      findsNothing,
      reason: 'nakon čišćenja filtera lista mora ponovo imati zapise',
    );
  });

  testWidgets('paginacija prelazi na sljedeću stranicu', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Korisnici');
    await waitFor(tester, find.textContaining('Prikazano 1 do'));

    await tapAndSettle(tester, find.byIcon(Icons.arrow_forward));
    await waitFor(
      tester,
      find.textContaining('Prikazano 11 do'),
      reason: 'druga stranica mora početi od 11. zapisa',
    );

    await tapAndSettle(tester, find.byIcon(Icons.arrow_back));
    await waitFor(tester, find.textContaining('Prikazano 1 do'));
  });
}
