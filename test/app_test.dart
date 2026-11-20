import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparein_mobile/main.dart';

void main() {
  testWidgets('bottom bar berpindah ke tiap halaman modul', (tester) async {
    await tester.pumpWidget(const SpareinApp());
    const titles = {
      'Devices': 'Devices',
      'Diagnostics': 'Diagnostics',
      'Guides': 'Guides',
      'Parts': 'Parts',
      'Journal': 'Jurnal Perbaikan',
    };
    for (final MapEntry(key: tab, value: title) in titles.entries) {
      await tester.tap(find.widgetWithText(NavigationDestination, tab));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(title)),
        findsOneWidget,
      );
    }
  });
}
