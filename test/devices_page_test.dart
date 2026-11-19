import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/devices/devices_page.dart';

Widget _page(MockClient client) => MaterialApp(
  home: DevicesPage(
    api: ApiClient(baseUrl: 'http://host', client: client),
  ),
);

void main() {
  testWidgets('menampilkan kartu device dari api', (tester) async {
    await tester.pumpWidget(
      _page(
        MockClient(
          (_) async => http.Response(
            '{"count":1,"results":[{"name":"iPhone 12","slug":"iphone-12",'
            '"brand":"Apple","category_name":"Phone","image_url":""}]}',
            200,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('iPhone 12'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
  });

  testWidgets('menampilkan pesan saat api gagal', (tester) async {
    await tester.pumpWidget(
      _page(MockClient((_) async => http.Response('', 500))),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gagal memuat perangkat.'), findsOneWidget);
  });
}
