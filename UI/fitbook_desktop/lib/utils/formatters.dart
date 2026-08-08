String _two(int value) => value.toString().padLeft(2, '0');

String formatDateTime(DateTime? utc) {
  if (utc == null) return '—';
  final local = utc.toLocal();
  return '${_two(local.day)}.${_two(local.month)}.${local.year}. ${_two(local.hour)}:${_two(local.minute)}';
}

String formatDate(DateTime? date) {
  if (date == null) return '';
  return '${_two(date.day)}.${_two(date.month)}.${date.year}.';
}

String formatMoney(num amount, [String currency = 'USD']) {
  final normalized = currency.trim().toUpperCase();
  final value = amount.toStringAsFixed(2);
  return switch (normalized) {
    'USD' => '\$$value',
    'EUR' => '€$value',
    'GBP' => '£$value',
    'BAM' || 'KM' => '$value KM',
    _ => '$value $normalized',
  };
}

String formatIsoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

String formatDateStamp(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}${_two(date.month)}${_two(date.day)}';

DateTime startOfDayUtc(DateTime day) => DateTime(day.year, day.month, day.day).toUtc();

DateTime endOfDayUtc(DateTime day) => DateTime(day.year, day.month, day.day + 1)
    .subtract(const Duration(microseconds: 1))
    .toUtc();

int calendarDaysBetween(DateTime from, DateTime to) =>
    DateTime.utc(to.year, to.month, to.day)
        .difference(DateTime.utc(from.year, from.month, from.day))
        .inDays;
