import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:fitbook_desktop/models/requests/reservations_report_request.dart';
import 'package:fitbook_desktop/providers/report_provider.dart';
import 'package:fitbook_desktop/utils/api_client_exception.dart';

import 'helpers.dart';

/// Upute traže najmanje dva izvještaja koja se mogu preuzeti kao PDF.
/// Ekranski test to ne može dokazati jer "Preuzmi PDF" otvara sistemski
/// dijalog za snimanje, pa se ovdje kroz isti provider koji ekran koristi
/// dohvataju stvarni bajtovi i provjerava da su ispravan PDF dokument.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Izvještaj o rezervacijama se dobija kao ispravan PDF', (
    tester,
  ) async {
    await launchApp(tester, freshSession: true);
    await goToScreen(tester, 'Izvještaji');
    await waitFor(tester, find.textContaining('Termini od'));

    final bytes = await reportProvider(
      tester,
    ).getReservationsReport(_wholeYearRequest());

    _expectPdf(bytes, 'izvještaj o rezervacijama');
  });

  testWidgets('Izvještaj o popularnosti treninga se dobija kao ispravan PDF', (
    tester,
  ) async {
    await launchApp(tester);
    await goToScreen(tester, 'Izvještaji');
    await waitFor(tester, find.textContaining('Termini od'));

    final bytes = await reportProvider(tester).getTrainingPopularityReport();

    _expectPdf(bytes, 'izvještaj o popularnosti treninga');
  });

  testWidgets('dva izvještaja daju dva različita dokumenta', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Izvještaji');
    await waitFor(tester, find.textContaining('Termini od'));

    final provider = reportProvider(tester);
    final rezervacije = await provider.getReservationsReport(
      _wholeYearRequest(),
    );
    final popularnost = await provider.getTrainingPopularityReport();

    _expectPdf(rezervacije, 'izvještaj o rezervacijama');
    _expectPdf(popularnost, 'izvještaj o popularnosti treninga');
    expect(
      rezervacije.length == popularnost.length &&
          rezervacije.take(2048).toList().toString() ==
              popularnost.take(2048).toList().toString(),
      isFalse,
      reason:
          'dva tražena izvještaja moraju biti stvarno različita dokumenta, '
          'a ne isti PDF vraćen dva puta',
    );
  });

  testWidgets('server odbija period sa krajem prije početka', (tester) async {
    await launchApp(tester);
    await goToScreen(tester, 'Izvještaji');
    await waitFor(tester, find.textContaining('Termini od'));

    await expectLater(
      reportProvider(tester).getReservationsReport(
        ReservationsReportRequest(
          fromDate: DateTime(2026, 12, 31),
          toDate: DateTime(2026, 1, 1),
        ),
      ),
      throwsA(
        isA<ApiClientException>().having(
          (e) => e.message,
          'poruka servera',
          contains('ne može biti prije početnog datuma'),
        ),
      ),
      reason:
          'period se mora provjeravati i na serveru, ne samo u formi na ekranu',
    );
  });
}

ReservationsReportRequest _wholeYearRequest() => ReservationsReportRequest(
  fromDate: DateTime(DateTime.now().year, 1, 1),
  toDate: DateTime(DateTime.now().year, 12, 31),
);

/// Ekran čita provider iz konteksta, pa test radi isto umjesto da pravi
/// vlastitu instancu — tako se koristi ista sesija i isti API klijent.
ReportProvider reportProvider(WidgetTester tester) => Provider.of<ReportProvider>(
  tester.element(find.byType(Scaffold).first),
  listen: false,
);

void _expectPdf(Uint8List bytes, String naziv) {
  expect(
    bytes.length,
    greaterThan(1000),
    reason: '$naziv mora biti stvaran dokument, a ne prazan odgovor',
  );
  expect(
    String.fromCharCodes(bytes.take(4)),
    '%PDF',
    reason: '$naziv mora početi PDF potpisom "%PDF"',
  );
  expect(
    String.fromCharCodes(bytes.skip(bytes.length - 8)),
    contains('%%EOF'),
    reason: '$naziv mora biti kompletan PDF (završava sa "%%EOF")',
  );
}
