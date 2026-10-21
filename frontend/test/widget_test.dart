import 'package:flutter_test/flutter_test.dart';
import 'package:centria/main.dart';

void main() {
  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CentriaApp());
    // Splash screen should show the app name
    expect(find.text('Centria'), findsOneWidget);
  });
}
