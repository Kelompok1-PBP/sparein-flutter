import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparein_mobile/main.dart';

void main() {
  testWidgets('bottom bar berpindah ke tiap halaman modul', (tester) async {
    await tester.pumpWidget(const SpareinApp());
    for (final name in [
      'Devices',
      'Diagnostics',
      'Guides',
      'Parts',
      'Journal',
    ]) {
      await tester.tap(find.widgetWithText(NavigationDestination, name));
      await tester.pumpAndSettle();
      expect(
        find.descendant(of: find.byType(AppBar), matching: find.text(name)),
        findsOneWidget,
      );
    }
  });
}
