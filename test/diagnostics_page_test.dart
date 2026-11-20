import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/diagnostics/diagnostics_page.dart';
import 'package:sparein_mobile/modules/diagnostics/diagnostics_service.dart';

const _body =
    '{"count":2,"results":['
    '{"id":1,"title":"Baterai boros","slug":"baterai-boros","description":"",'
    '"severity":"medium","severity_label":"Sedang","device":"iphone-12"},'
    '{"id":2,"title":"HP panas","slug":"hp-panas","description":"Panas saat dicas",'
    '"severity":"low","severity_label":"Ringan","device":"iphone-12"}]}';

Widget _page(MockClient client) => MaterialApp(
  home: DiagnosticsPage(
    api: ApiClient(baseUrl: 'http://host', client: client),
  ),
);

void main() {
  testWidgets('menampilkan kartu gejala dari api', (tester) async {
    await tester.pumpWidget(
      _page(MockClient((_) async => http.Response(_body, 200))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Baterai boros'), findsOneWidget);
    expect(find.text('Sedang'), findsOneWidget);
    expect(find.text('Panas saat dicas'), findsOneWidget);
    expect(find.text('Ringan'), findsOneWidget);
  });

  testWidgets('menampilkan pesan saat api gagal', (tester) async {
    await tester.pumpWidget(
      _page(MockClient((_) async => http.Response('', 500))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat gejala.'), findsOneWidget);
  });

  test('fetchSymptoms hanya mengirim filter yang terisi', () async {
    late Uri called;
    final service = DiagnosticsService(
      api: ApiClient(
        baseUrl: 'http://host',
        client: MockClient((request) async {
          called = request.url;
          return http.Response(_body, 200);
        }),
      ),
    );
    final symptoms = await service.fetchSymptoms(
      device: 'iphone-12',
      severity: '',
    );
    expect(called.queryParameters, {'device': 'iphone-12'});
    expect(symptoms.map((s) => s.title), ['Baterai boros', 'HP panas']);
  });
}
