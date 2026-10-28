import 'package:flutter_test/flutter_test.dart';
import 'package:centria/app/app.dart';

void main() {
  testWidgets('Centria App launches with Splash Screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CentriaApp());
    await tester.pumpAndSettle();

    // Verify Centria Brand Header renders
    expect(find.text('CENTRIA'), findsOneWidget);
    expect(find.text('Authenticate Executive Enclave'), findsOneWidget);
    expect(find.text('Provision New Corporate Tenant / Signup'), findsOneWidget);
  });
}
