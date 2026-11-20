import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/journal/journal_format.dart';
import 'package:sparein_mobile/modules/journal/journal_page.dart';

const _site = '{"repairs":4,"waste_avoided_kg":1.5,"cost_avoided":12500000}';

Widget _page(MockClient client) => MaterialApp(
  home: JournalPage(
    api: ApiClient(baseUrl: 'http://host', client: client),
  ),
);

void main() {
  testWidgets('visitor melihat counter situs dan ajakan masuk', (tester) async {
    await tester.pumpWidget(
      _page(
        MockClient(
          (_) async => http.Response(
            '{"summary":null,"site":$_site,"by_status":null}',
            200,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('4'), findsOneWidget);
    expect(find.text('1,5 kg'), findsOneWidget);
    expect(find.text('Rp 12,5 juta'), findsOneWidget);
    expect(find.text('Catat perbaikanmu sendiri'), findsOneWidget);
  });

  testWidgets('member melihat dampak pribadinya', (tester) async {
    await tester.pumpWidget(
      _page(
        MockClient(
          (_) async => http.Response(
            '{"summary":{"repairs":1,"waste_avoided_kg":0.2,"cost_avoided":2500000},'
            '"site":$_site,"by_status":{"planned":0,"in_progress":0,'
            '"succeeded":1,"failed":0}}',
            200,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('0,2 kg'), findsOneWidget);
    expect(find.text('Rp 2,5 juta'), findsOneWidget);
    expect(find.text('Catat perbaikanmu sendiri'), findsNothing);
  });

  testWidgets('menampilkan pesan saat api gagal', (tester) async {
    await tester.pumpWidget(
      _page(MockClient((_) async => http.Response('', 500))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat jurnal.'), findsOneWidget);
  });

  group('JournalFormat (sama dengan journal/formatting.py)', () {
    test('rupiah ditulis lengkap dengan titik', () {
      expect(JournalFormat.rupiah(1500000), 'Rp 1.500.000');
    });

    test('rupiahShort pindah ke juta dan miliar', () {
      expect(JournalFormat.rupiahShort(999999), 'Rp 999.999');
      expect(JournalFormat.rupiahShort(2500000), 'Rp 2,5 juta');
      expect(JournalFormat.rupiahShort(3000000), 'Rp 3 juta');
      expect(JournalFormat.rupiahShort(1250000000), 'Rp 1,3 miliar');
    });

    test('kg memakai koma dan membuang nol di belakang', () {
      expect(JournalFormat.kg(0), '0 kg');
      expect(JournalFormat.kg(0.2), '0,2 kg');
      expect(JournalFormat.kg(0.35), '0,35 kg');
    });
  });
}
