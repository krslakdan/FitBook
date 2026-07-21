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

String formatRelativeTime(DateTime? utc) {
  if (utc == null) return '—';
  final diff = DateTime.now().difference(utc.toLocal());
  if (diff.inSeconds < 60) return 'Upravo';
  if (diff.inMinutes < 60) return 'prije ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'prije ${diff.inHours} h';
  if (diff.inDays < 7) return 'prije ${diff.inDays} d';
  return formatDateTime(utc);
}
