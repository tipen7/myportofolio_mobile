/// Calendar date of [date] as UTC midnight, the format the Django web form
/// stores. Using UTC keeps the day stable across time zones.
DateTime dateOnlyUtc(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);

String formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/'
    '${date.month.toString().padLeft(2, '0')}/${date.year}';

String formatPeriod(DateTime? start, DateTime? end) {
  final from = start == null ? '-' : formatDate(start);
  final to = end == null ? 'Sekarang' : formatDate(end);
  return '$from - $to';
}
