import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fitbook_desktop/main.dart';
import 'package:fitbook_desktop/widgets/crud/form_dialog.dart';

const desktopUsername = 'desktop';
const desktopPassword = 'test';

String uniqueSuffix() =>
    DateTime.now().microsecondsSinceEpoch.remainder(100000000).toString();

Future<void> settle(WidgetTester tester, {int maxFrames = 120}) async {
  for (var i = 0; i < maxFrames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
    if (!tester.binding.hasScheduledFrame) return;
  }
}

Future<void> waitFor(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  throw TestFailure(
    'Isteklo vrijeme čekanja na: ${reason ?? finder.toString()}\n'
    'Vidljivo na ekranu: ${visibleTexts().join(" | ")}',
  );
}

/// Everything currently rendered as text, used to explain timeouts.
List<String> visibleTexts({int limit = 200, bool scopeToDialog = true}) {
  final result = <String>[];
  final dialog = find.byType(FormDialogShell);
  final scope = scopeToDialog && dialog.evaluate().isNotEmpty
      ? find.descendant(of: dialog, matching: find.byType(Text))
      : find.byType(Text);
  for (final element in scope.evaluate()) {
    final data = (element.widget as Text).data;
    if (data != null && data.trim().isNotEmpty) result.add(data.trim());
    if (result.length >= limit) break;
  }
  return result;
}

Future<void> waitForGone(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }
  }
  throw TestFailure(
    'Element nije nestao u zadatom vremenu: ${reason ?? finder.toString()}',
  );
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder.first);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(finder.first, warnIfMissed: false);
  await settle(tester);
}

Future<void> launchApp(WidgetTester tester, {bool freshSession = false}) async {
  await tester.binding.setSurfaceSize(const Size(1680, 1050));

  if (freshSession) {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  await tester.pumpWidget(const FitBookDesktopApp());
  await settle(tester);

  final loginButton = find.widgetWithText(FilledButton, 'Prijavi se');
  if (loginButton.evaluate().isEmpty) return;

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), desktopUsername);
  await tester.enterText(fields.at(1), desktopPassword);
  await settle(tester);
  await tapAndSettle(tester, loginButton);

  await waitFor(
    tester,
    find.text('Dashboard'),
    reason: 'dashboard nakon prijave',
  );
}

/// Sidebar tile is the first match for the label because the sidebar is
/// rendered before the content area in the Row.
Future<void> goToScreen(WidgetTester tester, String navLabel) async {
  final target = find.text(navLabel);
  if (target.evaluate().isEmpty) {
    try {
      await tester.scrollUntilVisible(
        target,
        120,
        scrollable: find.byType(Scrollable).first,
      );
    } catch (_) {
      throw TestFailure(
        'Stavka "$navLabel" ne postoji u bočnoj navigaciji '
        '(provjeri da li se labela razlikuje od naslova ekrana).',
      );
    }
    await settle(tester);
  }
  await tapAndSettle(tester, target.first);
  await settle(tester);
}

Finder dialogFields() => find.descendant(
  of: find.byType(FormDialogShell),
  matching: find.byType(TextFormField),
);

Future<void> fillDialogField(
  WidgetTester tester,
  int index,
  String value,
) async {
  final field = dialogFields().at(index);
  await tester.ensureVisible(field);
  await tester.enterText(field, value);
  await tester.pump(const Duration(milliseconds: 150));
}

Future<void> saveDialog(WidgetTester tester) async {
  await tapAndSettle(tester, find.widgetWithText(FilledButton, 'Sačuvaj'));
}

/// Taps save and polls for the confirmation message. Deliberately avoids
/// settle() afterwards, because settling pumps past the SnackBar's 4s life.
///
/// A rejection from the server is reported the moment the form shows its error
/// box, so a failing rule reads as "server je odbio …" instead of an anonymous
/// timeout thirty seconds later.
Future<void> saveDialogExpectingMessage(
  WidgetTester tester,
  String fragment, {
  Duration timeout = const Duration(seconds: 30),
}) async {
  await tester.tap(
    find.widgetWithText(FilledButton, 'Sačuvaj'),
    warnIfMissed: false,
  );

  final serverError = find.descendant(
    of: find.byType(FormDialogShell),
    matching: find.byIcon(Icons.error_outline),
  );
  final deadline = DateTime.now().add(timeout);

  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 100));

    if (find.textContaining(fragment).evaluate().isNotEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
      return;
    }

    if (serverError.evaluate().isNotEmpty) {
      throw TestFailure(
        'Server je odbio snimanje umjesto da vrati poruku "$fragment".\n'
        'Sadržaj forme: ${visibleTexts().join(" | ")}',
      );
    }
  }

  throw TestFailure(
    'Isteklo vrijeme čekanja na poruku "$fragment" nakon snimanja.\n'
    'Vidljivo: ${visibleTexts().join(" | ")}',
  );
}

Future<void> cancelDialog(WidgetTester tester) async {
  await tapAndSettle(tester, find.widgetWithText(OutlinedButton, 'Otkaži'));
}

/// Types into the screen's search box and waits out the debounce so the table
/// is narrowed to a single record before row actions are used.
Future<void> searchFor(WidgetTester tester, String term) async {
  await tester.enterText(find.byType(TextField).first, term);
  await tester.pump(const Duration(milliseconds: 700));
  await settle(tester);
}

Future<void> openRowAction(WidgetTester tester, String tooltip) async {
  await waitFor(tester, find.byTooltip(tooltip));
  await tapAndSettle(tester, find.byTooltip(tooltip));
}

Future<void> confirmDelete(WidgetTester tester, {String? expectMessage}) async {
  await waitFor(tester, find.widgetWithText(FilledButton, 'Obriši'));
  await tester.tap(
    find.widgetWithText(FilledButton, 'Obriši').last,
    warnIfMissed: false,
  );
  if (expectMessage != null) {
    await waitFor(
      tester,
      find.textContaining(expectMessage),
      reason: 'poruka "$expectMessage" nakon brisanja',
    );
  }
  await settle(tester);
}

/// Dropdowns are generic (DropdownButtonFormField&lt;int&gt;, &lt;bool?&gt;, ...) so
/// they are matched by runtime type name rather than a concrete type.
Finder dropdowns({Finder? within}) {
  final all = find.byWidgetPredicate(
    (w) => w.runtimeType.toString().startsWith('DropdownButtonFormField'),
  );
  return within == null
      ? all
      : find.descendant(of: within, matching: all);
}

Finder dialogDropdowns() => dropdowns(within: find.byType(FormDialogShell));

/// Reads option labels out of the menu overlay once the dropdown is open.
/// DropdownButtonFormField does not expose its `items` list publicly.
List<String> openMenuOptions() {
  final items = find.byWidgetPredicate(
    (w) => w.runtimeType.toString().startsWith('DropdownMenuItem'),
    skipOffstage: false,
  );
  final labels = <String>[];
  for (final element in items.evaluate()) {
    final child = (element.widget as dynamic).child;
    if (child is Text && (child.data ?? '').isNotEmpty) {
      labels.add(child.data!);
    }
  }
  return labels;
}

/// Every DropdownButtonFormField in the tree keeps its items mounted, so the
/// options of other dropdowns (notably the filter bar behind a dialog) are
/// indistinguishable by type alone. Diffing the labels before and after the
/// tap leaves exactly the entries the opened menu added, in menu order.
Future<String> selectDropdownOption(
  WidgetTester tester,
  Finder dropdown, {
  String? optionText,
  List<String> skip = const [],
  List<String>? optionsOut,
}) async {
  // dropdowns on some forms are populated from the API, so they may not
  // exist yet when the dialog first opens
  await waitFor(tester, dropdown, reason: 'padajuća lista');

  final before = openMenuOptions();
  await tapAndSettle(tester, dropdown);

  if (optionText != null) {
    final option = find.text(optionText);
    if (option.evaluate().isEmpty) {
      throw TestFailure(
        'Opcija "$optionText" ne postoji u meniju. Ponuđeno: ${openMenuOptions()}',
      );
    }
    await tapAndSettle(tester, option.last);
    return optionText;
  }

  final remaining = [...before];
  final menuLabels = <String>[];
  for (final label in openMenuOptions()) {
    if (remaining.remove(label)) continue;
    menuLabels.add(label);
  }
  optionsOut?..clear()..addAll(menuLabels);

  final target = menuLabels.firstWhere(
    (l) => !skip.contains(l),
    orElse: () => throw TestFailure(
      'Otvoreni meni nema upotrebljivu opciju (ponuđeno: $menuLabels).',
    ),
  );
  await tapAndSettle(tester, find.text(target).last);
  return target;
}

/// Chooses [day] in an already-open Material date picker.
///
/// The calendar's PageView also builds the neighbouring months, so the same
/// day number exists off-screen. Tapping one of those lands on the modal
/// barrier and silently cancels the picker, so the cell is located by
/// geometry and only tapped when its centre falls inside the dialog.
Future<void> pickCalendarDay(WidgetTester tester, int day) async {
  final datePicker = find.byType(DatePickerDialog);
  await waitFor(tester, datePicker, reason: 'kalendar');

  final dayCell = find.descendant(of: datePicker, matching: find.text('$day'));
  final pickerRect = tester.getRect(datePicker);
  Offset? target;
  for (var i = 0; i < dayCell.evaluate().length; i++) {
    final centre = tester.getRect(dayCell.at(i)).center;
    if (pickerRect.contains(centre)) {
      target = centre;
      break;
    }
  }
  if (target == null) {
    throw TestFailure('Dan "$day" nije vidljiv unutar kalendara.');
  }

  await tester.tapAt(target);
  await settle(tester);

  // depending on the Flutter version the calendar either closes on selection
  // or waits for an explicit confirm button
  if (datePicker.evaluate().isNotEmpty) {
    final confirm = find.descendant(
      of: datePicker,
      matching: find.byType(TextButton),
    );
    if (confirm.evaluate().isNotEmpty) {
      await tapAndSettle(tester, confirm.last);
    }
  }
}

/// Taps a date field and picks [day]; used by screens that ask for a date only.
Future<void> pickDate(WidgetTester tester, Finder field, int day) async {
  await tapAndSettle(tester, field);
  await pickCalendarDay(tester, day);
  await settle(tester);
}

/// Taps a date-time field, picks [day], then confirms the time picker.
Future<void> pickDateTime(
  WidgetTester tester,
  Finder field, {
  required int day,
  int? hour,
  int? minute,
}) async {
  await tapAndSettle(tester, field);
  await pickCalendarDay(tester, day);

  final timePicker = find.byType(TimePickerDialog);
  await waitFor(tester, timePicker, reason: 'odabir vremena');

  if (hour != null && minute != null) {
    for (final icon in [
      Icons.keyboard_outlined,
      Icons.keyboard,
      Icons.keyboard_alt_outlined,
    ]) {
      final toggle = find.descendant(
        of: timePicker,
        matching: find.byIcon(icon),
      );
      if (toggle.evaluate().isNotEmpty) {
        await tapAndSettle(tester, toggle);
        break;
      }
    }
    final inputs = find.descendant(
      of: timePicker,
      matching: find.byType(TextField),
    );
    if (inputs.evaluate().length >= 2) {
      await tester.enterText(inputs.at(0), hour.toString().padLeft(2, '0'));
      await tester.enterText(inputs.at(1), minute.toString().padLeft(2, '0'));
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  final timeConfirm = find.descendant(
    of: timePicker,
    matching: find.byType(TextButton),
  );
  if (timeConfirm.evaluate().isNotEmpty) {
    await tapAndSettle(tester, timeConfirm.last);
  }
  await settle(tester);

  final controller = (tester.widget(field) as TextFormField).controller;
  if ((controller?.text ?? '').isEmpty) {
    throw TestFailure(
      'Datum i vrijeme nisu popunjeni nakon odabira (dan=$day).',
    );
  }
}

void expectSnackBar(String fragment) {
  expect(
    find.textContaining(fragment),
    findsWidgets,
    reason: 'očekivana poruka koja sadrži "$fragment"',
  );
}
