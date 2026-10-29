import 'package:flutter_test/flutter_test.dart';
import 'package:centria/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CentriaApp(hasSeenSplash: true));
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Centria'), findsWidgets);
  });
}
