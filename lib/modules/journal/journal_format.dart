/// Format angka dan tanggal Jurnal, terjemahan dari `journal/formatting.py` di web
/// supaya tampilan di aplikasi sama dengan situs.
class JournalFormat {
  const JournalFormat._();

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// `1500000` jadi `Rp 1.500.000`.
  static String rupiah(int value) => 'Rp ${_dots(value)}';

  /// `2500000` jadi `Rp 2,5 juta`, `1250000000` jadi `Rp 1,3 miliar`.
  static String rupiahShort(int value) {
    if (value < 1000000) return rupiah(value);
    // Dibulatkan setengah ke atas, dihitung dalam persepuluhan supaya bebas galat double.
    final millionsTenths = (value + 50000) ~/ 100000;
    if (millionsTenths < 10000) return 'Rp ${_tenths(millionsTenths)} juta';
    final billionsTenths = (value + 50000000) ~/ 100000000;
    return 'Rp ${_tenths(billionsTenths)} miliar';
  }

  /// `0.2` jadi `0,2 kg`, `1` jadi `1 kg`, `0.35` jadi `0,35 kg`.
  static String kg(double value) {
    final hundredths = (value * 100).round();
    final whole = hundredths ~/ 100;
    final fraction = hundredths % 100;
    if (fraction == 0) return '$whole kg';
    if (fraction % 10 == 0) return '$whole,${fraction ~/ 10} kg';
    return '$whole,${fraction.toString().padLeft(2, '0')} kg';
  }

  /// `2026-10-01` jadi `1 Okt 2026`. String kosong atau tidak valid jadi kosong.
  static String shortDate(String? iso) {
    final date = iso == null ? null : DateTime.tryParse(iso);
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  static String _dots(int number) => number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => '.',
  );

  static String _tenths(int tenths) {
    final whole = tenths ~/ 10;
    final fraction = tenths % 10;
    return fraction == 0 ? '$whole' : '$whole,$fraction';
  }
}
