import 'package:flutter_test/flutter_test.dart';
import 'package:sparein_mobile/main.dart';

void main() {
  testWidgets('aplikasi tampil', (tester) async {
    await tester.pumpWidget(const SpareinApp());
    expect(find.text('Sparein'), findsOneWidget);
  });
}
