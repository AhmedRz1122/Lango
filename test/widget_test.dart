import 'package:flutter_test/flutter_test.dart';
import 'package:lango/main.dart';

void main() {
  testWidgets('Lango app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const LangoApp());
    expect(find.text('Lango'), findsOneWidget);
  });
}
