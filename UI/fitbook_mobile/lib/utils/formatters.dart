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

const List<String> _weekdayShort = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

String weekdayShort(DateTime? date) {
  if (date == null) return '';
  return _weekdayShort[date.weekday - 1];
}

const List<String> _monthShort = [
  'Jan', 'Feb', 'Mar', 'Apr', 'Maj', 'Jun', 'Jul', 'Avg', 'Sep', 'Okt', 'Nov', 'Dec',
];

String monthShort(DateTime? date) {
  if (date == null) return '';
  return _monthShort[date.month - 1];
}

String formatDateWithWeekday(DateTime? date) {
  if (date == null) return '';
  return '${weekdayShort(date)}, ${formatDate(date)}';
}

String formatTimeRange(DateTime startUtc, DateTime endUtc) {
  final start = startUtc.toLocal();
  final end = endUtc.toLocal();
  return '${_two(start.hour)}:${_two(start.minute)} - ${_two(end.hour)}:${_two(end.minute)}';
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

String formatMembershipDuration(int days) {
  if (days > 0 && days % 365 == 0) {
    final years = days ~/ 365;
    if (years == 1) return '1 godina';
    if (years < 5) return '$years godine';
    return '$years godina';
  }
  if (days > 0 && days % 30 == 0) {
    final months = days ~/ 30;
    if (months == 1) return '1 mjesec';
    if (months < 5) return '$months mjeseca';
    return '$months mjeseci';
  }
  if (days == 1) return '1 dan';
  return '$days dana';
}

String formatDaysRemaining(int days) {
  if (days <= 0) return 'Istječe danas';
  if (days == 1) return 'Još 1 dan';
  if (days < 5) return 'Još $days dana';
  return 'Još $days dana';
}

String formatRelativeTime(DateTime? utc) {
  if (utc == null) return '—';
  final diff = DateTime.now().difference(utc.toLocal());
  if (diff.inSeconds < 60) return 'Upravo';
  if (diff.inMinutes < 60) return 'prije ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'prije ${diff.inHours} h';
  if (diff.inDays < 7) return 'prije ${diff.inDays} d';
  return formatDateTime(utc);
}
