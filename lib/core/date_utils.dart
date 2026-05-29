/// Tiny date helpers used across the app.
/// We store dates as ISO strings (yyyy-mm-dd) in SQLite for simplicity.

DateTime today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

String fmtDate(DateTime d) {
  final m = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$m-$dd';
}

DateTime parseDate(String s) {
  final parts = s.split('-');
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

int daysBetween(DateTime a, DateTime b) {
  final aa = DateTime(a.year, a.month, a.day);
  final bb = DateTime(b.year, b.month, b.day);
  return bb.difference(aa).inDays;
}
