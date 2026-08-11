import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Trener: početni ekran "Danas"', (tester) async {
    await launchApp(tester, username: trainerUsername);
    await goToTab(tester, 'Danas');
    await settle(tester);

    expect(find.text('Danas'), findsWidgets);
    expect(
      find.textContaining('Termina danas'),
      findsWidgets,
      reason: 'trenerski dashboard mora prikazati broj termina',
    );
  });

  testWidgets('Trener: lista termina i filteri', (tester) async {
    await launchApp(tester, username: trainerUsername);
    await goToTab(tester, 'Termini');
    await waitFor(tester, find.text('Termini koje vodite'));

    expect(find.text('Aktivni'), findsWidgets);

    await tapAndSettle(tester, find.text('Prošli').last);
    await settle(tester);
    await tapAndSettle(tester, find.text('Aktivni').last);
    await settle(tester);
  });

  testWidgets('Trener: detalji termina sa listom rezervacija', (tester) async {
    await launchApp(tester, username: trainerUsername);
    await goToTab(tester, 'Termini');
    await waitFor(tester, find.text('Termini koje vodite'));

    if (itemsOfType('_TermCard').evaluate().isEmpty) {
      markTestSkipped('Trener trenutno nema nijedan aktivan termin.');
      return;
    }

    await tapAndSettle(tester, itemsOfType('_TermCard').first);
    await settle(tester);

    expect(
      find.textContaining('Rezervacije'),
      findsWidgets,
      reason: 'detalji termina moraju prikazati listu rezervacija',
    );

    await goBack(tester);
    await settle(tester);
  });

  testWidgets('Trener: notifikacije prikazuju listu ili prazno stanje', (
    tester,
  ) async {
    await launchApp(tester, username: trainerUsername);
    await goToTab(tester, 'Notifikacije');
    await settle(tester);

    expect(find.text('Notifikacije'), findsWidgets);
    expect(
      itemsOfType('_NotificationTile').evaluate().isNotEmpty ||
          find.text('Nema notifikacija').evaluate().isNotEmpty,
      isTrue,
      reason: 'lista notifikacija trenera mora biti učitana',
    );
  });

  testWidgets('Trener: profil i odjava', (tester) async {
    await launchApp(tester, username: trainerUsername);
    await goToTab(tester, 'Profil');
    await settle(tester);

    expect(find.text('Odjava'), findsWidgets);
    await logout(tester);
    expect(find.text('Dobrodošli nazad'), findsWidgets);
  });
}
