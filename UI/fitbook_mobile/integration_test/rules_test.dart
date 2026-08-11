import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fitbook_mobile/widgets/trainer_avatar.dart';

import 'helpers.dart';

/// Pravila iz uputa koja se ne vide kroz osnovni tok ekrana:
/// objašnjive preporuke, oznaka pročitano na notifikacijama i onemogućene
/// akcije sa objašnjenjem razloga.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Preporuke na početnoj nose objašnjenje zašto su preporučene', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Početna');
    await waitFor(tester, find.text('Preporučeno za vas'));

    await scrollTo(tester, find.byIcon(Icons.lightbulb_outline));

    final cards = itemsOfType('_RecommendationCard');
    final prazno = find.textContaining('personalizovane preporuke');

    if (cards.evaluate().isEmpty) {
      expect(
        prazno,
        findsOneWidget,
        reason:
            'kada nema preporuka mora se prikazati jasno objašnjenje umjesto '
            'prazne sekcije',
      );
      markTestSkipped('Korisnik trenutno nema kandidata za preporuku.');
      return;
    }

    expect(
      find.byIcon(Icons.lightbulb_outline),
      findsWidgets,
      reason: 'svaka preporuka mora imati red sa objašnjenjem',
    );

    // objašnjenja moraju odgovarati modelu iz recommender dokumentacije:
    // content-based (kategorija) ili popularity-based
    final content = find.textContaining('često birate treninge iz kategorije');
    final popularnost = find.textContaining('Popularan trening');
    expect(
      content.evaluate().isNotEmpty || popularnost.evaluate().isNotEmpty,
      isTrue,
      reason:
          'objašnjenje mora biti jedno od dva dokumentovana: content-based po '
          'kategoriji ili popularity-based',
    );
  });

  testWidgets('Preporučeni trening vodi na svoje detalje', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Početna');
    await waitFor(tester, find.text('Preporučeno za vas'));

    final cards = itemsOfType('_RecommendationCard');
    await scrollTo(tester, cards);
    if (cards.evaluate().isEmpty) {
      markTestSkipped('Korisnik trenutno nema kandidata za preporuku.');
      return;
    }

    await tapAndSettle(tester, cards.first);
    await waitFor(
      tester,
      find.text('Trajanje'),
      reason: 'preporuka mora otvoriti detalje treninga',
    );
    expect(find.text('Max učesnika'), findsWidgets);

    await goBack(tester);
    await settle(tester);
  });

  testWidgets('Termini prikazuju sliku trenera uz njegovo ime', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Treninzi');
    await waitFor(tester, find.text('Pregled dostupnih treninga'));

    final trainingCount = itemsOfType('_TrainingCard').evaluate().length;
    var opened = false;

    for (var i = 0; i < trainingCount && !opened; i++) {
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
      opened = true;
    }

    expect(opened, isTrue, reason: 'nijedan trening nema zakazanih termina');

    expect(
      find.byType(TrainerAvatar),
      findsWidgets,
      reason: 'kartica termina mora prikazati sliku trenera uz njegovo ime',
    );

    await tapAndSettle(tester, itemsOfType('TermCard').first);
    await waitFor(tester, find.text('Detalji termina'));
    expect(
      find.byType(TrainerAvatar),
      findsWidgets,
      reason: 'detalji termina moraju prikazati sliku trenera',
    );

    await goBack(tester);
    await settle(tester);
  });

  testWidgets('Notifikacije: nepročitane se mogu označiti kao pročitane', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Profil');
    await waitFor(tester, find.text('Notifikacije'));
    await tapAndSettle(tester, find.text('Notifikacije'));
    await settle(tester);

    if (itemsOfType('_NotificationTile').evaluate().isEmpty) {
      expect(find.text('Nema notifikacija'), findsOneWidget);
      markTestSkipped('Korisnik nema nijednu notifikaciju.');
      return;
    }

    final oznaciSve = find.text('Označi sve');
    if (oznaciSve.evaluate().isEmpty) {
      markTestSkipped('Sve notifikacije su već pročitane.');
      return;
    }

    expect(
      find.textContaining('nepročitanih'),
      findsWidgets,
      reason: 'zaglavlje mora prikazivati broj nepročitanih notifikacija',
    );

    await tapAndSettle(tester, oznaciSve);
    await waitForGone(
      tester,
      find.textContaining('nepročitanih'),
      reason: 'brojač nepročitanih nakon označavanja svih kao pročitanih',
    );
    expect(
      find.text('Označi sve'),
      findsNothing,
      reason: 'akcija nestaje kada više nema nepročitanih notifikacija',
    );

    // ekran se otvara kao zasebna ruta i mijenja stanje na serveru, pa se
    // sesija zatvara kako naredni test ne bi krenuo iz zatečenog stanja
    await goBack(tester);
    await logout(tester);
  });

  testWidgets('Članarina: kupovina paketa je onemogućena uz objašnjenje', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Članarina');
    await waitFor(tester, find.text('Paketi članarine'));

    final odaberi = find.widgetWithText(FilledButton, 'Odaberi paket');
    await scrollTo(tester, odaberi);
    await waitFor(tester, odaberi, reason: 'kartice paketa članarine');

    final button = tester.widget<FilledButton>(odaberi.first);
    expect(
      button.onPressed,
      isNull,
      reason:
          'korisnik sa aktivnom članarinom ne smije moći kupiti novi paket '
          'direktno',
    );
    expect(
      find.textContaining('Već imate aktivnu članarinu'),
      findsWidgets,
      reason: 'onemogućena akcija mora objasniti razlog nedostupnosti',
    );
    expect(
      find.textContaining('Promijeni paket'),
      findsWidgets,
      reason: 'objašnjenje mora uputiti korisnika na ispravnu akciju',
    );
  });

  testWidgets('Članarina: paketi prikazuju cijenu i period', (tester) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Članarina');
    await waitFor(tester, find.text('Paketi članarine'));

    final kartice = itemsOfType('_PackageCard');
    await scrollTo(tester, kartice);
    expect(
      kartice.evaluate().isNotEmpty,
      isTrue,
      reason: 'lista paketa članarine mora biti popunjena iz baze',
    );

    expect(
      find.textContaining('KM').evaluate().isNotEmpty ||
          find.textContaining('\$').evaluate().isNotEmpty ||
          find.textContaining('USD').evaluate().isNotEmpty,
      isTrue,
      reason: 'kartica paketa mora prikazati cijenu',
    );
  });

  testWidgets('Detalji članarine prikazuju rok i historiju plaćanja', (
    tester,
  ) async {
    await launchApp(tester, username: memberUsername);
    await goToTab(tester, 'Članarina');
    await waitFor(tester, find.text('Vaše članstvo i paketi'));

    if (find.textContaining('Vrijedi do').evaluate().isEmpty) {
      markTestSkipped('Korisnik trenutno nema aktivnu članarinu.');
      return;
    }

    expect(
      find.text('Aktivna članarina'),
      findsWidgets,
      reason: 'status članarine mora biti jasno označen',
    );

    await tapAndSettle(tester, find.byTooltip('Historija članarina'));
    await waitFor(tester, find.text('Sve Vaše članarine'));
    expect(
      find.text('Aktivne'),
      findsWidgets,
      reason: 'historija mora nuditi filtriranje po statusu članarine',
    );

    await goBack(tester);
    await waitFor(tester, find.text('Vaše članstvo i paketi'));
  });

  /// Otkazivanje je konačno stanje: razlog mora ostati zapisan, a akcija
  /// otkazivanja se više ne smije nuditi.
  testWidgets('Otkazana rezervacija čuva razlog i nema više akciju otkazivanja', (
    tester,
  ) async {
    await launchApp(tester, username: cancelledReservationUsername);
    await goToTab(tester, 'Rezervacije');
    await waitFor(tester, find.text('Vaše rezervacije treninga'));

    await tapAndSettle(tester, find.text('Prošle'));
    await settle(tester);

    final otkazana = find.ancestor(
      of: find.text('Otkazano'),
      matching: itemsOfType('_ReservationCard'),
    );
    await scrollTo(tester, otkazana);
    if (otkazana.evaluate().isEmpty) {
      markTestSkipped('Korisnik nema otkazanih rezervacija.');
      return;
    }

    await tapAndSettle(tester, otkazana.first);
    await waitFor(
      tester,
      find.text('Detalji rezervacije'),
      reason: 'detalji otkazane rezervacije',
    );

    expect(
      find.text('Otkazano'),
      findsWidgets,
      reason: 'status otkazane rezervacije mora ostati vidljiv u detaljima',
    );

    await scrollTo(tester, find.text('Razlog otkazivanja'));
    expect(
      find.text('Razlog otkazivanja'),
      findsOneWidget,
      reason: 'upisani razlog otkazivanja mora biti prikazan korisniku',
    );

    expect(
      find.widgetWithText(FilledButton, 'Otkaži rezervaciju'),
      findsNothing,
      reason:
          'već otkazana rezervacija se ne smije moći otkazati ponovo '
          '(pravilo prelaza statusa se poštuje i u aplikaciji)',
    );

    await goBack(tester);
    await waitFor(tester, find.text('Vaše rezervacije treninga'));
  });
}
