import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparein_mobile/main.dart';

void main() {
  testWidgets('bilah navigasi membuka setiap halaman modul', (tester) async {
    await tester.pumpWidget(const SpareinApp());
    const judulHalaman = {
      'Devices': 'Devices',
      'Diagnostics': 'Diagnostics',
      'Panduan': 'Panduan Perbaikan',
      'Parts': 'Parts',
      'Journal': 'Journal',
    };
    for (final tab in judulHalaman.entries) {
      await tester.tap(find.widgetWithText(NavigationDestination, tab.key));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text(tab.value),
        ),
        findsOneWidget,
      );
    }
  });
}
