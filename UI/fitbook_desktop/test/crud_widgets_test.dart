
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitbook_desktop/theme/app_theme.dart';
import 'package:fitbook_desktop/widgets/crud/data_table_card.dart';
import 'package:fitbook_desktop/widgets/crud/filter_bar.dart';
import 'package:fitbook_desktop/widgets/crud/table_action_buttons.dart';
import 'package:fitbook_desktop/widgets/status_chip.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: buildAppTheme(),
    home: Scaffold(body: child),
  );
}

void main() {
  testWidgets('FilterBar sa poljima i akcijama se renderuje bez layout grešaka', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        Column(
          children: [
            FilterBar(
              fields: [
                FilterField(
                  label: 'Pretraga',
                  width: 260,
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Pretraga...',
                      prefixIcon: Icon(Icons.search, size: 20),
                    ),
                  ),
                ),
                FilterField(
                  label: 'Status',
                  width: 150,
                  child: DropdownButtonFormField<bool?>(
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Svi statusi')),
                      DropdownMenuItem(value: true, child: Text('Aktivan')),
                    ],
                    onChanged: (_) {},
                  ),
                ),
              ],
              actions: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Dodaj'),
                ),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                  label: const Text('Očisti filtere'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Dodaj'), findsOneWidget);
    expect(find.text('Očisti filtere'), findsOneWidget);
  });

  testWidgets('DataTableCard renderuje redove, chipove, akcije i paginaciju', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        DataTableCard<String>(
          title: 'Lista testova',
          items: const ['Prvi zapis', 'Drugi zapis'],
          page: 2,
          pageSize: 10,
          totalCount: 154,
          totalPages: 16,
          itemsLabel: 'zapisa',
          onRefresh: () {},
          onPageChanged: (_) {},
          onPageSizeChanged: (_) {},
          columns: const [
            ColumnSpec('Naziv', flex: 2),
            ColumnSpec('Status', width: 110),
            ColumnSpec('Akcije', width: 116),
          ],
          cellsBuilder: (context, item) => [
            Text(item),
            const StatusChip(label: 'Aktivan', tone: ChipTone.success),
            TableActionButtons(onView: () {}, onEdit: () {}, onDelete: () {}),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Lista testova'), findsOneWidget);
    expect(find.text('Prvi zapis'), findsOneWidget);
    expect(find.text('Prikazano 11 do 12 od 154 zapisa'), findsOneWidget);
    expect(find.text('16'), findsOneWidget);
    expect(find.text('…'), findsOneWidget);
  });

  testWidgets('DataTableCard prazno stanje prikazuje poruku', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        DataTableCard<String>(
          title: 'Lista testova',
          items: const [],
          page: 1,
          pageSize: 10,
          totalCount: 0,
          totalPages: 0,
          emptyMessage: 'Nema zapisa za zadate filtere.',
          onRefresh: () {},
          onPageChanged: (_) {},
          onPageSizeChanged: (_) {},
          columns: const [ColumnSpec('Naziv')],
          cellsBuilder: (context, item) => [Text(item)],
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Nema zapisa za zadate filtere.'), findsOneWidget);
  });
}
