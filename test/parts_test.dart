import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sparein_mobile/core/network/api_client.dart';
import 'package:sparein_mobile/modules/parts/models/part.dart';
import 'package:sparein_mobile/modules/parts/parts_page.dart';
import 'package:sparein_mobile/modules/parts/parts_service.dart';
import 'package:sparein_mobile/modules/parts/widgets/parts_widgets.dart';

const _listJson = {
  'count': 2,
  'next': null,
  'previous': null,
  'results': [
    {
      'id': 1,
      'name': 'Baterai iPhone 11',
      'slug': 'baterai-iphone-11',
      'part_number': 'BAT-IP11',
      'category': 'battery',
      'category_label': 'Baterai',
      'image_url': '',
      'source_count': 2,
      'lowest_price': 185000,
      'highest_price': 210000,
    },
    {
      'id': 2,
      'name': 'Layar iPhone 11 LCD',
      'slug': 'layar-iphone-11-lcd',
      'part_number': '',
      'category': 'screen',
      'category_label': 'Layar',
      'image_url': '',
      'source_count': 0,
    },
  ],
};

const _detailJson = {
  'id': 1,
  'name': 'Baterai iPhone 11',
  'slug': 'baterai-iphone-11',
  'part_number': 'BAT-IP11',
  'category': 'battery',
  'category_label': 'Baterai',
  'description': 'Baterai pengganti kapasitas standar 3110 mAh.',
  'image_url': '',
  'source_count': 2,
  'compatibilities': [
    {'device_name': 'iPhone 11', 'device_slug': 'iphone-11', 'note': ''},
  ],
  'sources': [
    {
      'vendor_name': 'Sinar Ponsel',
      'city': 'Depok',
      'price': 185000,
      'currency': 'IDR',
      'url': 'https://example.com/baterai',
      'contact': '0812-0000-0001',
      'last_checked': '2026-10-27',
    },
    {
      'vendor_name': 'Mitra Servis HP',
      'city': 'Jakarta Selatan',
      'price': 210000,
      'currency': 'IDR',
      'url': 'https://example.com/baterai-2',
      'contact': '',
      'last_checked': '2026-10-20',
    },
  ],
};

/// Service dengan MockClient. [calls] mencatat setiap URL yang dipanggil.
PartsService _service(List<Uri> calls, {bool Function()? fail}) {
  return PartsService(
    api: ApiClient(
      baseUrl: 'http://host',
      client: MockClient((request) async {
        calls.add(request.url);
        if (fail?.call() ?? false) return http.Response('', 500);
        final body = switch (request.url.path) {
          '/api/v1/parts/' => _listJson,
          '/api/v1/parts/baterai-iphone-11/' => _detailJson,
          _ => null,
        };
        if (body == null) return http.Response('', 404);
        return http.Response.bytes(utf8.encode(jsonEncode(body)), 200);
      }),
    ),
  );
}

void main() {
  group('Part.fromJson', () {
    test('item visitor tanpa harga tetap terbaca', () {
      final part = Part.fromJson({
        'id': 3,
        'name': 'Kabel USB-C 1 m',
        'slug': 'kabel-usb-c-1-m',
        'category': 'cable',
        'source_count': 2,
        'sources': [
          {
            'vendor_name': 'Pusat Aksesori Cell',
            'city': 'Surabaya',
            'url': 'https://example.com',
            'last_checked': '2026-10-27',
          },
        ],
      });
      expect(part.categoryLabel, 'Kabel'); // fallback dari partCategories
      expect(part.partNumber, '');
      expect(part.lowestPrice, isNull);
      expect(part.sources.single.price, isNull);
      expect(part.sources.single.contact, isNull);
      expect(part.sources.single.lastChecked, DateTime(2026, 10, 27));
    });

    test('item member membawa harga dan kecocokan perangkat', () {
      final part = Part.fromJson(_detailJson);
      expect(part.lowestPrice, isNull); // detail tidak wajib kirim agregat
      expect(part.sources.map((s) => s.price), [185000, 210000]);
      expect(part.compatibilities.single.deviceName, 'iPhone 11');
    });
  });

  test('formatRupiah memakai titik sebagai pemisah ribuan', () {
    expect(formatRupiah(185000), 'Rp185.000');
    expect(formatRupiah(1150000), 'Rp1.150.000');
    expect(formatRupiah(500), 'Rp500');
  });

  test('daysAgo', () {
    final now = DateTime(2026, 11, 20, 15);
    expect(daysAgo(DateTime(2026, 11, 20), now: now), 'Hari ini');
    expect(daysAgo(DateTime(2026, 11, 19), now: now), 'Kemarin');
    expect(daysAgo(DateTime(2026, 10, 27), now: now), '24 hari lalu');
  });

  test('fetchParts menerima list biasa tanpa pagination', () async {
    final service = PartsService(
      api: ApiClient(
        baseUrl: 'http://host',
        client: MockClient(
          (_) async => http.Response(jsonEncode(_listJson['results']), 200),
        ),
      ),
    );
    final parts = await service.fetchParts();
    expect(parts.map((p) => p.slug), [
      'baterai-iphone-11',
      'layar-iphone-11-lcd',
    ]);
  });

  testWidgets('daftar tampil, tap kartu membuka detail, back kembali', (
    tester,
  ) async {
    final calls = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(home: PartsPage(service: _service(calls))),
    );
    await tester.pumpAndSettle();

    expect(find.text('2 suku cadang'), findsOneWidget);
    expect(find.text('Mulai Rp185.000 · 2 toko'), findsOneWidget);
    expect(find.text('Harga belum tersedia'), findsOneWidget);

    await tester.tap(find.text('Baterai iPhone 11'));
    await tester.pumpAndSettle();

    expect(calls.last.path, '/api/v1/parts/baterai-iphone-11/');
    expect(find.text('Tempat beli'), findsOneWidget);
    expect(find.text('Sinar Ponsel'), findsOneWidget);
    expect(find.text('iPhone 11'), findsOneWidget);
    expect(
      find.text('Kisaran Rp185.000 sampai Rp210.000 dari 2 toko'),
      findsOneWidget,
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('2 suku cadang'), findsOneWidget);
  });

  testWidgets('pencarian dan chip kategori dikirim sebagai query', (
    tester,
  ) async {
    final calls = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(home: PartsPage(service: _service(calls))),
    );
    await tester.pumpAndSettle();
    expect(calls.single.query, isEmpty);

    await tester.enterText(find.byType(TextField), 'baterai');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(calls.last.queryParameters, {'q': 'baterai'});

    await tester.tap(find.widgetWithText(FilterChip, 'Layar'));
    await tester.pumpAndSettle();
    expect(calls.last.queryParameters, {'q': 'baterai', 'category': 'screen'});

    // Tap chip yang sama lagi untuk membatalkan filter kategori.
    await tester.tap(find.widgetWithText(FilterChip, 'Layar'));
    await tester.pumpAndSettle();
    expect(calls.last.queryParameters, {'q': 'baterai'});
  });

  testWidgets('error menampilkan tombol coba lagi yang memuat ulang', (
    tester,
  ) async {
    var failing = true;
    final calls = <Uri>[];
    await tester.pumpWidget(
      MaterialApp(
        home: PartsPage(service: _service(calls, fail: () => failing)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat suku cadang'), findsOneWidget);

    failing = false;
    await tester.tap(find.text('Coba lagi'));
    await tester.pumpAndSettle();

    expect(find.text('2 suku cadang'), findsOneWidget);
    expect(calls, hasLength(2));
  });
}
